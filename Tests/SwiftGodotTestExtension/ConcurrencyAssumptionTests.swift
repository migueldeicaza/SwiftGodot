//
//  ConcurrencyAssumptionTests.swift
//  SwiftGodotTestExtension
//
//  Checks the Swift runtime behaviors that `GodotMainActor` and `emitted` rely on, so a
//  toolchain change that breaks one of them fails here first.
//

import SwiftGodot
import SwiftGodotTestMacros

private func isGodotMainThread() -> Bool {
    OS.getThreadCallerId() == OS.getMainThreadId()
}

/// Runs `withTaskCancellationHandler` from a `nonisolated(nonsending)` function, as
/// `awaitOneShotSignal` does, and reports where its operation closure ran.
private nonisolated(nonsending) func operationThreadFromNonsending() async -> Bool {
    await withTaskCancellationHandler {
        isGodotMainThread()
    } onCancel: {
    }
}

@SwiftGodotTestSuite
final class ConcurrencyAssumptionTests {
    /// `withTaskCancellationHandler`'s operation runs on the caller's actor when called
    /// from code isolated to it.
    @GodotMainActor
    public func testCancellationHandlerOperationRunsOnTheCallersActor() async {
        let onMain = await withTaskCancellationHandler {
            isGodotMainThread()
        } onCancel: {
        }
        assertTrue(onMain, "operation closure left Godot's main thread")
    }

    /// The same, through a `nonisolated(nonsending)` function: the case `emitted` relies
    /// on to connect and disconnect from the caller's actor.
    @GodotMainActor
    public func testCancellationHandlerOperationRunsOnTheCallersActorThroughNonsending() async {
        let onMain = await operationThreadFromNonsending()
        assertTrue(onMain, "operation closure left Godot's main thread")
    }

    /// ...and stays there after suspending inside it, as `emitted`'s does.
    @GodotMainActor
    public func testCancellationHandlerOperationStaysOnTheActorAcrossASuspension() async throws {
        let onMain = try await withTaskCancellationHandler {
            try await GodotFrames().next()
            return isGodotMainThread()
        } onCancel: {
        }
        assertTrue(onMain, "operation closure resumed off Godot's main thread")
    }
}
