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
    /// `CancellationError`.  As with the typed version, if the emitting object is gone -
    /// before the await starts or while it is waiting - the await throws
    /// ``SignalAwaitError/targetUnavailable``.
    ///
    /// - Throws: `CancellationError` if the task is cancelled, or ``SignalAwaitError``.
    nonisolated(nonsending) var emitted: [Variant?] {
        get async throws {
            guard targetIsValid else {
                throw SignalAwaitError.targetUnavailable
            }

            return try await awaitOneShotSignal(
                decode: { (arguments: borrowing Arguments) throws(ArgumentAccessError) -> [Variant?] in
                    Array(arguments)
                },
                connect: { callable in
                    // `Signal.connect` reports a raw error code rather than a GodotError.
                    // Anything other than OK is a failure, including codes GodotError
                    // does not know.
                    let result = connect(
                        callable: callable,
                        flags: Int64(Object.ConnectFlags.oneShot.rawValue))
                    if result != GodotError.ok.rawValue {
                        throw SignalAwaitError.connectionFailed(GodotError(rawValue: result) ?? .failed)
                    }
                },
                disconnect: { callable in
                    if targetIsValid, isConnected(callable: callable) {
                        disconnect(callable: callable)
                    }
                })
        }
    }

    private var targetIsValid: Bool {
        GD.isInstanceIdValid(id: getObjectId())
    }
}
