//
//  GodotMainActorTests.swift
//  SwiftGodotTestExtension
//

import SwiftGodot
import SwiftGodotTestMacros

/// Records the last frame on which its `_process` ran.
@Godot
final class ProcessFrameRecorder: Node {
    var lastProcessedFrame: Int = -1

    override func _process(delta: Double) {
        lastProcessedFrame = Int(Engine.getProcessFrames())
    }
}

/// Records which frame a task resumed on after awaiting a signal.
private final class ResumeRecorder: @unchecked Sendable {
    var resumedOnFrame: Int?
}

private nonisolated func callAssumingIsolation(_ flag: ResumeRecorder) {
    GodotMainActor.assumeIsolated {
        flag.resumedOnFrame = Int(Engine.getProcessFrames())
    }
}

@SwiftGodotTestSuite
final class GodotMainActorTests {
    public static var registeredTypes: [Object.Type] {
        [ProcessFrameRecorder.self]
    }

    @GodotMainActor
    public func testJobsRunOnGodotsMainThread() async throws {
        assertEqual(OS.getThreadCallerId(), OS.getMainThreadId())
        let onMain = await Task { @GodotMainActor in
            OS.getThreadCallerId() == OS.getMainThreadId()
        }.value
        assertTrue(onMain)
    }

    /// A frame wait resumes at the start of the frame, before any node's `_process`.
    @GodotMainActor
    public func testFrameWaitsResumeBeforeProcess() async throws {
        let recorder = ProcessFrameRecorder()
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            fail("no SceneTree")
            return
        }
        tree.root.addChild(node: recorder)
        let frames = GodotFrames()
        try await frames.wait(frames: 2)
        for _ in 0 ..< 5 {
            try await frames.next()
            let frame = Int(Engine.getProcessFrames())
            assertEqual(recorder.lastProcessedFrame, frame - 1, "_process hasn't run yet this frame")
        }
        recorder.queueFree()
    }

    /// A task awaiting a signal that is emitted during the drain resumes in that same drain,
    /// every time, rather than whenever the resume makes it back from the thread pool.
    @GodotMainActor
    public func testSignalResumesLandInTheSameDrain() async throws {
        let frames = GodotFrames()
        for attempt in 0 ..< 20 {
            let emitter = Node()
            let recorder = ResumeRecorder()
            let task = Task { @GodotMainActor in
                try await emitter.renamed.emitted
                recorder.resumedOnFrame = Int(Engine.getProcessFrames())
            }
            try await frames.next()
            assertEqual(emitter.getSignalConnectionList(signal: "renamed").count, 1, "attempt \(attempt): connected")
            let emittedOnFrame = Int(Engine.getProcessFrames())
            emitter.renamed.emit()
            try await frames.next()
            assertEqual(recorder.resumedOnFrame, emittedOnFrame, "attempt \(attempt): resumed in the drain it was emitted in")
            _ = try await task.value
            emitter.queueFree()
        }
    }

    @GodotMainActor
    public func testAssumeIsolatedFromSynchronousMainThreadCode() async throws {
        let recorder = ResumeRecorder()
        callAssumingIsolation(recorder)
        assertNotNil(recorder.resumedOnFrame)
    }

    @GodotMainActor
    public func testFramesWithoutAnOwnerAdvanceEveryFrame() async throws {
        let frames = GodotFrames()
        let start = Engine.getProcessFrames()
        try await frames.wait(frames: 3)
        assertEqual(Engine.getProcessFrames() - start, 3)
    }

    @GodotMainActor
    public func testFrameWaitsHonorTaskCancellation() async throws {
        let task = Task { @GodotMainActor in
            try await GodotFrames().wait(frames: 1000)
        }
        try await waitFrames(2)
        task.cancel()
        do {
            try await task.value
            fail("cancelled wait should throw")
        } catch is CancellationError {
        }
    }
}
