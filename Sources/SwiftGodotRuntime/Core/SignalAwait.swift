//
//  SignalAwait.swift
//  SwiftGodot
//
//  The machinery behind awaiting a single signal emission, shared by the typed
//  `SignalWithArguments.emitted` and the untyped `Signal.emitted`.
//

/// Failures that can interrupt awaiting ``SignalWithArguments/emitted`` or
/// ``Signal/emitted``.
public enum SignalAwaitError: Error, CustomStringConvertible {
    /// The object that declares the signal is gone: either it was already gone when the
    /// await began, or it was destroyed before the signal fired.
    case targetUnavailable

    /// Godot refused to connect to the signal.
    case connectionFailed(GodotError)

    /// The signal fired, but its arguments could not be converted to the Swift types the
    /// signal declares - for example a `null` object for a non-optional `Node`, or a
    /// float emitted from GDScript for an `Int` argument.
    case payloadMismatch(ArgumentAccessError)

    public var description: String {
        switch self {
        case .targetUnavailable:
            return "The object that declares this signal is no longer available"
        case .connectionFailed(let error):
            return "Godot refused the signal connection: \(error)"
        case .payloadMismatch(let error):
            return "The signal's arguments did not match its declared types: \(error)"
        }
    }
}

/// The identity of one awaited connection.
///
/// Godot's connection owns the callable, and the callable owns this object, so it lives
/// exactly as long as the connection does.  That gives the await two things it cannot
/// otherwise get:
///
/// - **Notice that the emitter went away.**  When Godot drops the connection without
///   having called it - because the object was freed - the callable is released and
///   `deinit` runs.  After a normal emission it also runs, but the await has already
///   settled by then and the notification is ignored.
/// - **A way to disconnect without keeping the callable alive.**  Callables built with
///   the same identity compare equal, so cancellation can build a fresh one to pass to
///   `disconnect`.  Holding on to the connected callable instead would keep its closure
///   alive and hide the moment Godot drops it.
final class OneShotConnection {
    private let onRelease: () -> Void

    init(onRelease: @escaping () -> Void) {
        self.onRelease = onRelease
    }

    deinit {
        onRelease()
    }

    /// A callable that compares equal to every other callable made from this connection.
    func makeCallable(_ body: @escaping (borrowing Arguments) -> Void) -> Callable {
        Callable(takingOver: CallableWrapper.callableVariantContent(
            wrapping: { arguments in
                body(arguments)
                return nil
            },
            identity: self))
    }
}

/// Coordinates a single one-shot signal await.
///
/// The continuation is resumed exactly once, by whichever of these happens first: the
/// signal fires, the connection is refused or dropped, or the task is cancelled.  Godot
/// emits from whatever thread it pleases, connections are released from whatever thread
/// frees the emitter, and `withTaskCancellationHandler`'s `onCancel` is `@Sendable`, so
/// every transition goes through the lock.
final class OneShotAwaiter<Payload> {
    private let lock = NIOLock()
    private var continuation: CheckedContinuation<Payload, any Error>?
    private weak var connection: OneShotConnection?
    private var isSettled = false
    private var cancelledBeforeStart = false

    /// Installs the continuation.
    ///
    /// Returns `false` when cancellation arrived before the operation body ran, in which
    /// case the continuation has already been resumed and no connection should be made.
    func begin(_ c: CheckedContinuation<Payload, any Error>) -> Bool {
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

    /// Records the connection so a cancelled await can disconnect itself.
    ///
    /// Held weakly: Godot's connection is what keeps it alive, and a strong reference here
    /// would stop `OneShotConnection` from noticing when Godot lets go.  Cancellation can
    /// occur before `connect` returns, so this is recorded even when already settled.
    func connected(_ c: OneShotConnection) {
        lock.withLockVoid {
            connection = c
        }
    }

    /// Hands back the connection, if Godot still holds it and it is ours to drop.
    func takeConnection() -> OneShotConnection? {
        lock.withLock { () -> OneShotConnection? in
            let c = connection
            connection = nil
            return c
        }
    }

    func fulfill(_ payload: Payload) {
        takeContinuation()?.resume(returning: payload)
    }

    func fail(_ error: any Error) {
        takeContinuation()?.resume(throwing: error)
    }

    func cancel() {
        let c = lock.withLock { () -> CheckedContinuation<Payload, any Error>? in
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

    private func takeContinuation() -> CheckedContinuation<Payload, any Error>? {
        lock.withLock { () -> CheckedContinuation<Payload, any Error>? in
            guard !isSettled else { return nil }
            isSettled = true
            let c = continuation
            continuation = nil
            return c
        }
    }
}

/// Waits for one emission of a signal.
///
/// - Parameters:
///   - decode: turns the emitted arguments into the payload.  A thrown error fails the
///     await with ``SignalAwaitError/payloadMismatch(_:)``.
///   - connect: connects the callable as a one-shot connection, throwing
///     ``SignalAwaitError`` when that is not possible.
///   - disconnect: drops the connection on cancellation.  It receives a callable equal to
///     the connected one, and must tolerate the emitter or the connection being gone.
///
/// `nonisolated(nonsending)`, so `connect` and `disconnect` run on the caller's actor.
nonisolated(nonsending) func awaitOneShotSignal<Payload>(
    decode: @escaping (borrowing Arguments) throws(ArgumentAccessError) -> Payload,
    connect: (Callable) throws -> Void,
    disconnect: (Callable) -> Void
) async throws -> Payload {
    let awaiter = OneShotAwaiter<Payload>()

    do {
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { c in
                guard awaiter.begin(c) else { return }

                // Capture the awaiter weakly in both closures.  Godot's connection owns
                // them, and the awaiter is kept alive by this async frame for as long as
                // either can fire; a strong capture would only lengthen the life of an
                // awaiter nobody is waiting on.
                let connection = OneShotConnection { [weak awaiter] in
                    awaiter?.fail(SignalAwaitError.targetUnavailable)
                }
                let callable = connection.makeCallable { [weak awaiter] arguments in
                    do throws(ArgumentAccessError) {
                        let payload = try decode(arguments)
                        awaiter?.fulfill(payload)
                    } catch {
                        awaiter?.fail(SignalAwaitError.payloadMismatch(error))
                    }
                }

                // Keep both alive until the outcome is recorded: if the connection is
                // refused, releasing them would run `connection`'s deinit and report
                // the wrong error.
                withExtendedLifetime((connection, callable)) {
                    do {
                        try connect(callable)
                        awaiter.connected(connection)
                    } catch {
                        awaiter.fail(error)
                    }
                }
            }
        } onCancel: {
            awaiter.cancel()
        }
    } catch {
        // Cancellation can be delivered from any thread, so the handler above only
        // resumes the continuation.  The actual disconnect happens here, back on the
        // caller's actor.
        if let connection = awaiter.takeConnection() {
            disconnect(connection.makeCallable { _ in })
        }
        throw error
    }
}
