//
//  AwaitScriptCall.swift
//  SwiftGodot
//
//  Awaiting a call into a script.
//
//  GDScript's `await` accepts a signal or a call to a coroutine - a function that itself
//  contains `await`. Calling a coroutine does not return its value: it returns a handle
//  to the suspended call, which emits `completed` with the value once it resumes.
//
//  That handle is `GDScriptFunctionState`, which is not published in
//  `extension_api.json`, so it crosses the boundary as an object of a class the binding
//  does not know statically. Everything here therefore goes through the dynamic `Signal`
//  API rather than a generated type.
//

public extension Object {
    /// Calls a script method and, if the call suspended at an `await`, waits for it to
    /// finish.
    ///
    /// A method that does not suspend has its value returned directly - the equivalent of
    /// GDScript's "redundant await", which is harmless.
    ///
    /// ```swift
    /// // func slow(tree):
    /// //     await tree.process_frame
    /// //     return 42
    /// let value = try await object.callScriptAsync(method: "slow", tree.toVariant())
    /// ```
    ///
    /// Waiting requires frames to advance, so call this from somewhere that lets Godot
    /// keep running - not from a context that blocks the main thread.
    ///
    /// - Throws: whatever ``callScript(method:_:)`` throws, `CancellationError` if the
    ///   task is cancelled while waiting, or ``SignalAwaitError``.
    nonisolated(nonsending) func callScriptAsync(
        method: StringName,
        _ arguments: Variant?...
    ) async throws -> Variant? {
        let result = try callScript(method: method, arguments: arguments)

        guard let state = result?.to(Object.self), state.isSuspendedScriptCall else {
            return result
        }

        // `completed` carries the coroutine's return value as its single argument.
        let values = try await Signal(object: state, signal: "completed").emitted
        return values.first ?? nil
    }

    /// Whether this object is a handle to a script call that suspended at an `await`.
    ///
    /// Recognised structurally rather than by class name: the handle emits `completed`
    /// when the call resumes and answers `is_valid` while it is still pending.  No
    /// ordinary return value looks like that.
    private var isSuspendedScriptCall: Bool {
        hasSignal("completed") && hasMethod("is_valid")
    }
}
