//
//  Created by Sam Deane on 25/10/2024.
//

/// Simple signal without arguments.
public typealias SimpleSignal = SignalWithArguments< /* no args */>

/// Failures that can interrupt awaiting ``SignalWithArguments/emitted``.
public enum SignalAwaitError: Error, CustomStringConvertible {
    /// The object that declares the signal was already gone when the await began.
    case targetUnavailable

    /// Godot refused to connect to the signal.
    case connectionFailed(GodotError)

    public var description: String {
        switch self {
        case .targetUnavailable:
            return "The object that declares this signal is no longer available"
        case .connectionFailed(let error):
            return "Godot refused the signal connection: \(error)"
        }
    }
}

/// Coordinates a single one-shot signal await.
///
/// The continuation is resumed exactly once, by whichever of these happens first: the
/// signal fires, the connection is refused, or the task is cancelled.  Godot emits from
/// whatever thread it pleases and `withTaskCancellationHandler`'s `onCancel` is
/// `@Sendable`, so every transition goes through the lock.
private final class SignalAwaiter<each T: _GodotBridgeable> {
    private let lock = NIOLock()
    private var continuation: CheckedContinuation<(repeat each T), any Error>?
    private var token: Callable?
    private var isSettled = false
    private var cancelledBeforeStart = false

    /// Installs the continuation.
    ///
    /// Returns `false` when cancellation arrived before the operation body ran, in which
    /// case the continuation has already been resumed and no connection should be made.
    func begin(_ c: CheckedContinuation<(repeat each T), any Error>) -> Bool {
        let alreadyCancelled = lock.withLock { () -> Bool in
            if cancelledBeforeStart {
                return true
            }
            continuation = c
            return false
        }

        if alreadyCancelled {
            c.resume(throwing: CancellationError())
            return false
        }
        return true
    }

    /// Records the connection token so a cancelled await can disconnect itself.
    ///
    /// Nothing is recorded once the awaiter has settled: the one-shot connection is
    /// already gone, and there would be no later opportunity to drop the reference.
    func connected(_ callable: Callable) {
        lock.withLockVoid {
            guard !isSettled else { return }
            token = callable
        }
    }

    /// Hands back the connection token, if the connection is still ours to drop.
    func takeToken() -> Callable? {
        lock.withLock { () -> Callable? in
            let t = token
            token = nil
            return t
        }
    }

    func fulfill(_ payload: (repeat each T)) {
        takeContinuation()?.resume(returning: payload)
    }

    func fail(_ error: any Error) {
        takeContinuation()?.resume(throwing: error)
    }

    func cancel() {
        let c = lock.withLock { () -> CheckedContinuation<(repeat each T), any Error>? in
            guard !isSettled else { return nil }
            isSettled = true
            guard let c = continuation else {
                // Cancellation beat the operation body; `begin` will resume instead.
                cancelledBeforeStart = true
                return nil
            }
            continuation = nil
            return c
        }
        c?.resume(throwing: CancellationError())
    }

    private func takeContinuation() -> CheckedContinuation<(repeat each T), any Error>? {
        lock.withLock { () -> CheckedContinuation<(repeat each T), any Error>? in
            guard !isSettled else { return nil }
            isSettled = true
            let c = continuation
            continuation = nil
            return c
        }
    }
}

/// Signal support.
/// Use the ``connect(flags:_:)`` method to connect to the signal on the container object,
/// and ``disconnect(_:)`` to drop the connection.
/// Use the ``emit(...)`` method to emit a signal.
/// You can also await the ``emitted`` property to wait for a single emission of the signal.
public struct SignalWithArguments<each T: _GodotBridgeable> {
    weak var target: Object?
    let signalName: StringName
    
    public init(target: Object, signalName: String) {
        self.target = target
        self.signalName = StringName(signalName)
    }

    /// Register this signal with the Godot runtime.
    public static func register<C: Object>(_ signalName: String, info: ClassInfo<C>, names: [String] = []) {
        info.registerSignal(name: StringName(signalName), arguments: getArgumentPropInfos(names))
    }

    /// Register ``SignalWithArguments`` with a set of arguments inferred from generic clause as a signal named `signalName` in a class named `className`.
    public static func register(as signalName: StringName, in className: StringName, names: [String] = []) {
        _registerSignal(signalName, in: className, arguments: getArgumentPropInfos(names))
    }

    /// Expand a list of argument types into a list of PropInfo objects
    static func getArgumentPropInfos(_ names: [String]) -> [PropInfo] {
        var arguments = [PropInfo]()
        var i = 1
        let nameCount = names.count

        for argument in repeat (each T)._argumentPropInfo(name: i > nameCount ? "arg\(i)" : names[i-1]) {
            arguments.append(argument)
            i += 1
        }
        
        return arguments
    }
    
    /// Connects the signal to the specified callback
    /// To disconnect, call the disconnect method, with the returned token on success
    ///
    /// - Parameters:
    /// - callback: the method to invoke when this signal is raised
    /// - flags: Optional, can be also added to configure the connection's behavior (see ``Object/ConnectFlags`` constants).
    /// - Returns: ``Callable`` that can be used to ``disconnect(_:)`` from the signal. Or ignored altogether.
    ///
    /// ### Example
    /// ```
    /// // someSignal: SignalWithArguments<String, Bool>
    /// someSignal.connect { string, bool in
    ///      // do something
    /// }
    /// ```
    @discardableResult
    public func connect(flags: Object.ConnectFlags = [], _ callback: @escaping (_ t: repeat each T) -> Void) -> Callable {
        let callable = Callable(callback)
        _ = target?.connect(signal: signalName, callable: callable, flags: UInt32(flags.rawValue))
        return callable
    }

    /// Disconnects a signal that was previously connected, the return value from calling
    /// ``connect(flags:_:)``
    public func disconnect(_ token: Callable) {
        target?.disconnect(signal: signalName, callable: token)
    }

    /// Emit the signal (with required arguments, if there are any)
    @discardableResult /* discardable per discardableList: Object, emit_signal */
    public func emit(_ t: repeat each T) -> GodotError {
        // NOTE:
        // Ideally we should be able to expand the arguments and pass them
        // into a call to the native emitSignal; something like this:
        //   emitSignal(signalName, repeat Variant(each t))
        //
        // Unfortunately, expanding arguments as opposed to types
        // (t, as opposed to T), doesn't seem to support this pattern.
        //
        // The only thing we can do with them is iterate them,
        // which means that we can build up an array of them, so we
        // then use callv to call the emit_signal method.
        let args = VariantArray()
        args.append(Variant(signalName))
        for arg in repeat each t {
            args.append(arg.toVariant())
        }
        
        guard let target else {
            return GodotError.failed
        }
        let result = target.callv(method: "emit_signal", argArray: args)
        guard let result else { return .ok }
        guard let errorCode = Int(result) else { return .ok }
        return GodotError(rawValue: Int64(errorCode))!
    }

    /// Await this property to wait for the signal to be emitted once.
    ///
    /// The value is the signal's payload: `()` for a ``SimpleSignal``, the argument itself
    /// for a signal with one argument, and a tuple otherwise.
    ///
    /// ```swift
    /// try await timer.timeout.emitted
    /// let (id, oldName, newName) = try await node.animationNodeRenamed.emitted
    /// ```
    ///
    /// Cancelling the awaiting task disconnects from the signal and throws
    /// `CancellationError`.  If the object that declares the signal is destroyed while you
    /// are waiting, the await does not resume - that mirrors GDScript's own `await`, so
    /// bound the wait with cancellation or a timeout when the emitter might not survive.
    ///
    /// This is `nonisolated(nonsending)`, so it runs on the caller's actor rather than
    /// hopping to the cooperative pool.  Resuming on the caller's actor is an ordinary
    /// language guarantee that would hold either way; what the attribute buys is keeping
    /// this getter's own `connect` and `disconnect` calls on that actor, instead of
    /// racing Godot's frame from a background thread.
    ///
    /// - Throws: `CancellationError` if the task is cancelled, or ``SignalAwaitError``.
    public nonisolated(nonsending) var emitted: (repeat each T) {
        get async throws {
            guard let target else {
                throw SignalAwaitError.targetUnavailable
            }

            let awaiter = SignalAwaiter<repeat each T>()

            do {
                return try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { c in
                        guard awaiter.begin(c) else { return }

                        // Capture the awaiter weakly. It holds the Callable so that a
                        // cancelled await can disconnect, and Godot's connection owns the
                        // Callable's wrapper, which owns this closure - so a strong
                        // capture would close the loop
                        // (awaiter -> Callable -> wrapper -> closure -> awaiter) and leak
                        // both on every completed await. The async frame below keeps the
                        // awaiter alive for as long as the callback can fire.
                        let callback: (repeat each T) -> Void = { [weak awaiter] (t: repeat each T) in
                            awaiter?.fulfill((repeat each t))
                        }
                        let callable = Callable(callback)

                        let result = target.connect(
                            signal: signalName,
                            callable: callable,
                            flags: UInt32(Object.ConnectFlags.oneShot.rawValue))

                        if result == .ok {
                            awaiter.connected(callable)
                        } else {
                            awaiter.fail(SignalAwaitError.connectionFailed(result))
                        }
                    }
                } onCancel: {
                    awaiter.cancel()
                }
            } catch {
                // Cancellation can be delivered from any thread, so the handler above only
                // resumes the continuation.  The actual disconnect happens here, back on
                // the caller's actor.  On the success path Godot has already dropped the
                // one-shot connection, and `takeToken` is only non-nil when it has not.
                if let token = awaiter.takeToken() {
                    target.disconnect(signal: signalName, callable: token)
                }
                throw error
            }
        }
    }
}
