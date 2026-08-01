//
//  SignalExtensions.swift
//  SwiftGodot
//
//  Awaiting a `Signal` value.
//
//  `Signal` is the builtin Variant type - the one you get back from GDScript, from
//  `Object.getSignalList()`, or by building it yourself with `Signal(object:signal:)`.
//  It is unrelated to `SignalWithArguments`, and it carries no static type information
//  about its arguments, so the payload here is untyped.
//

/// Coordinates a single one-shot await on a builtin ``Signal``.
///
/// Same contract as the awaiter behind ``SignalWithArguments/emitted``: the continuation
/// resumes exactly once, whether the signal fires, the connection is refused, or the task
/// is cancelled.  Godot emits from whatever thread it pleases and `onCancel` is
/// `@Sendable`, so every transition goes through the lock.
private final class VariantSignalAwaiter {
    private let lock = NIOLock()
    private var continuation: CheckedContinuation<[Variant?], any Error>?
    private var token: Callable?
    private var isSettled = false
    private var cancelledBeforeStart = false

    func begin(_ c: CheckedContinuation<[Variant?], any Error>) -> Bool {
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

    func connected(_ callable: Callable) {
        lock.withLockVoid {
            guard !isSettled else { return }
            token = callable
        }
    }

    func takeToken() -> Callable? {
        lock.withLock { () -> Callable? in
            let t = token
            token = nil
            return t
        }
    }

    func fulfill(_ payload: [Variant?]) {
        takeContinuation()?.resume(returning: payload)
    }

    func fail(_ error: any Error) {
        takeContinuation()?.resume(throwing: error)
    }

    func cancel() {
        let c = lock.withLock { () -> CheckedContinuation<[Variant?], any Error>? in
            guard !isSettled else { return nil }
            isSettled = true
            guard let c = continuation else {
                cancelledBeforeStart = true
                return nil
            }
            continuation = nil
            return c
        }
        c?.resume(throwing: CancellationError())
    }

    private func takeContinuation() -> CheckedContinuation<[Variant?], any Error>? {
        lock.withLock { () -> CheckedContinuation<[Variant?], any Error>? in
            guard !isSettled else { return nil }
            isSettled = true
            let c = continuation
            continuation = nil
            return c
        }
    }
}

public extension Signal {
    /// Await this property to wait for the signal to be emitted once.
    ///
    /// Unlike ``SignalWithArguments/emitted``, the payload is untyped: a ``Signal`` value
    /// carries no static information about its arguments, so you get the raw ``Variant``
    /// list that Godot passed to the callback.
    ///
    /// ```swift
    /// let args = try await signal.emitted
    /// let who = args.first??.to(String.self)
    /// ```
    ///
    /// Cancelling the awaiting task disconnects from the signal and throws
    /// `CancellationError`.  As with the typed version, an await does not resume if the
    /// emitting object is destroyed first.
    ///
    /// - Throws: `CancellationError` if the task is cancelled, or ``SignalAwaitError``.
    nonisolated(nonsending) var emitted: [Variant?] {
        get async throws {
            guard !isNull() else {
                throw SignalAwaitError.targetUnavailable
            }

            let awaiter = VariantSignalAwaiter()

            do {
                return try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { c in
                        guard awaiter.begin(c) else { return }

                        // Weak, for the same reason as the typed version: the awaiter
                        // holds the Callable, whose wrapper owns this closure, so a
                        // strong capture would form a cycle and leak every completed
                        // await. The async frame keeps the awaiter alive meanwhile.
                        let callable = Callable { [weak awaiter] (arguments: borrowing Arguments) -> Variant? in
                            awaiter?.fulfill(Array(arguments))
                            return nil
                        }

                        let result = connect(
                            callable: callable,
                            flags: Int64(Object.ConnectFlags.oneShot.rawValue))

                        // `Signal.connect` reports a raw error code rather than a GodotError.
                        if let error = GodotError(rawValue: result), error != .ok {
                            awaiter.fail(SignalAwaitError.connectionFailed(error))
                        } else {
                            awaiter.connected(callable)
                        }
                    }
                } onCancel: {
                    awaiter.cancel()
                }
            } catch {
                if let token = awaiter.takeToken() {
                    disconnect(callable: token)
                }
                throw error
            }
        }
    }
}
