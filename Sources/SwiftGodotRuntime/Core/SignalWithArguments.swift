//
//  Created by Sam Deane on 25/10/2024.
//

/// Simple signal without arguments.
public typealias SimpleSignal = SignalWithArguments< /* no args */>

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
    /// `CancellationError`.  If the object that declares the signal is gone - before the
    /// await starts or while it is waiting - the await throws
    /// ``SignalAwaitError/targetUnavailable``.  This differs from GDScript, whose `await`
    /// never resumes in that case.
    ///
    /// The await does not keep the object alive: a `RefCounted` emitter whose last other
    /// reference goes away is released, and the await then throws as above.
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
            // Never hold the target strongly across the suspension: `target` is weak so
            // that the signal does not keep its object alive, and an await should not
            // either.  Each closure below takes its own short-lived reference.
            guard target?.isValid == true else {
                throw SignalAwaitError.targetUnavailable
            }

            return try await awaitOneShotSignal(
                decode: { (arguments: borrowing Arguments) throws(ArgumentAccessError) -> (repeat each T) in
                    var index = 0
                    return (repeat try (each T).fromArguments(arguments, incrementingIndex: &index))
                },
                connect: { callable in
                    guard let target, target.isValid else {
                        throw SignalAwaitError.targetUnavailable
                    }
                    let result = target.connect(
                        signal: signalName,
                        callable: callable,
                        flags: UInt32(Object.ConnectFlags.oneShot.rawValue))
                    if result != .ok {
                        throw SignalAwaitError.connectionFailed(result)
                    }
                },
                disconnect: { callable in
                    // The emitter or the one-shot connection can be gone by now.
                    if let target, target.isValid,
                       target.isConnected(signal: signalName, callable: callable) {
                        target.disconnect(signal: signalName, callable: callable)
                    }
                })
        }
    }
}
