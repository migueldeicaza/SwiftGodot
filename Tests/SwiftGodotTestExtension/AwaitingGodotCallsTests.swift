//
//  AwaitingGodotCallsTests.swift
//  SwiftGodotTestExtension
//
//  What can actually be awaited when calling into Godot?
//
//  GDScript's `await` accepts two things: a signal, and a call to a *coroutine* - a
//  function that itself contains `await`. Awaiting a call to an ordinary function is
//  merely redundant. The signal half is covered by SignalTests; this file pins down the
//  call half, which had no coverage at all.
//

import SwiftGodot

@SwiftGodotTestSuite
final class AwaitingGodotCallsTests {
    /// A script with one coroutine and one ordinary function.
    ///
    /// `slow()` suspends on `process_frame`, so calling it returns before it has a value.
    /// `fast()` returns its value outright.
    private func makeScriptedObject() -> RefCounted? {
        let script = GDScript()
        script.sourceCode = """
        extends RefCounted

        func slow(tree):
            await tree.process_frame
            return 42

        func fast():
            return 7
        """

        let reloadResult = script.reload()
        guard reloadResult == .ok else {
            fail("GDScript.reload() failed with \(reloadResult)")
            return nil
        }

        let object = RefCounted()
        object.setScript(script.toVariant())
        return object
    }

    /// Calling a non-coroutine returns its value directly - GDScript's "redundant await".
    @GodotMainActor
    public func testCallingOrdinaryFunctionReturnsItsValue() async throws {
        guard let object = makeScriptedObject() else { return }

        let result = try object.callScript(method: "fast")
        assertEqual(result?.to(Int.self), 7, "a non-coroutine should return its value")
    }

    /// Calling a coroutine returns a handle to the suspended call, not the return value.
    ///
    /// This test records what that handle actually is. `GDScriptFunctionState` is not in
    /// `extension_api.json`, so it arrives as an object of a class the binding does not
    /// know statically - which is why `callScriptAsync` has to work through the dynamic
    /// `Signal` API rather than a generated type.
    @GodotMainActor
    public func testCallingCoroutineReturnsSuspendedCallHandle() async throws {
        guard let object = makeScriptedObject() else { return }
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            fail("no SceneTree")
            return
        }

        let result = try object.callScript(method: "slow", tree.toVariant())

        guard let state = result?.to(Object.self) else {
            fail("a suspended coroutine should return an object, got \(String(describing: result))")
            return
        }

        GD.print("[coroutine spike] class=\(state.getClass()) completed=\(state.hasSignal("completed"))")
        assertTrue(state.hasSignal("completed"),
                   "the suspended call should expose a `completed` signal")
        assertNotEqual(result?.to(Int.self), 42,
                       "the coroutine's value is not available yet at call time")
    }

    /// `callScriptAsync` papers over the difference: it awaits a coroutine to completion
    /// and returns an ordinary value straight through.
    @GodotMainActor
    public func testCallScriptAsyncAwaitsCoroutine() async throws {
        guard let object = makeScriptedObject() else { return }
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            fail("no SceneTree")
            return
        }

        let slow = try await object.callScriptAsync(method: "slow", tree.toVariant())
        assertEqual(slow?.to(Int.self), 42, "should have waited for the coroutine's value")

        let fast = try await object.callScriptAsync(method: "fast")
        assertEqual(fast?.to(Int.self), 7, "a non-coroutine should pass straight through")
    }
}
