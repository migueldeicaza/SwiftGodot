//
//  GodotTasksTests.swift
//  SwiftGodotTestExtension
//

import SwiftGodot
import SwiftGodotTestMacros

struct TaskTestFailure: Error {}

private func isGodotMainThread() -> Bool {
    OS.getThreadCallerId() == OS.getMainThreadId()
}

/// Waits `count` frames.
@GodotMainActor
func waitFrames(_ count: Int) async throws {
    try await GodotFrames().wait(frames: count)
}

/// Waits up to `limit` frames for `condition`, failing the test if it never holds.
@GodotMainActor
func waitUntil(frames limit: Int = 120, _ what: String, file: StaticString = #file, line: UInt = #line, _ condition: () -> Bool) async throws {
    for _ in 0 ..< limit {
        if condition() { return }
        try await GodotFrames().next()
    }
    if !condition() {
        fail("timed out waiting for \(what)", file: file, line: line)
    }
}

/// Starts tasks from nonisolated code capturing non-Sendable state, as a node's callbacks do.
final class TaskRecorder {
    var events: [String] = []
    var ready = false
    var ranOnMainThread = true
    let tasks: GodotTasks

    init(owner: Node) {
        tasks = GodotTasks(owner: owner)
    }

    func startWaiting(_ name: String = "wait") {
        tasks.run(name) { frames in
            self.ranOnMainThread = self.ranOnMainThread && isGodotMainThread()
            self.events.append("\(name) started")
            try await frames.waitUntil { self.ready }
            self.ranOnMainThread = self.ranOnMainThread && isGodotMainThread()
            self.events.append("\(name) done")
        }
    }

    func startTimer(seconds: Double) {
        tasks.run("timer") { frames in
            try await frames.wait(seconds: seconds)
            self.events.append("timer done")
        }
    }

    func startAwaitingRename(of other: Node) {
        tasks.run("signal") { frames in
            self.events.append("signal started")
            try await frames.wait(for: other.renamed)
            self.events.append("signal done")
        }
    }

    func startFailing() {
        tasks.run("boom") { _ in
            throw TaskTestFailure()
        }
    }
}

@SwiftGodotTestSuite
final class GodotTasksTests {
    @GodotMainActor
    private func makeOwner() throws -> Node {
        let owner = Node()
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            throw TaskTestFailure()
        }
        tree.root.addChild(node: owner)
        return owner
    }

    @GodotMainActor
    private func dispose(_ node: Node) async throws {
        if GD.isInstanceIdValid(id: Int64(node.getInstanceId())) {
            node.queueFree()
        }
        try await waitFrames(1)
    }

    @GodotMainActor
    public func testRunsOnTheMainThreadAndWaitsAcrossFrames() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startWaiting()
        assertEqual(recorder.events, [], "starts on a later frame")
        try await waitUntil("the task to start") { recorder.events == ["wait started"] }
        try await waitFrames(3)
        assertEqual(recorder.events, ["wait started"], "still waiting")
        recorder.ready = true
        try await waitUntil("the task to finish") { recorder.events.count == 2 }
        assertEqual(recorder.events, ["wait started", "wait done"])
        assertTrue(recorder.ranOnMainThread, "every part ran on the main thread")
        try await dispose(owner)
    }

    @GodotMainActor
    public func testRunningANameAgainReplacesTheTask() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startWaiting()
        try await waitUntil("the first task to start") { recorder.events.count == 1 }
        recorder.startWaiting()
        try await waitUntil("the second task to start") { recorder.events.count == 2 }
        recorder.ready = true
        try await waitFrames(3)
        assertEqual(recorder.events, ["wait started", "wait started", "wait done"], "only the replacement finishes")
        try await dispose(owner)
    }

    @GodotMainActor
    public func testReplacingBeforeTheFirstRunSkipsIt() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startWaiting()
        recorder.startWaiting()
        try await waitFrames(3)
        assertEqual(recorder.events, ["wait started"], "the replaced task never ran")
        try await dispose(owner)
    }

    @GodotMainActor
    public func testCancelledTasksDontContinue() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startWaiting("a")
        recorder.startWaiting("b")
        recorder.startWaiting("c")
        try await waitUntil("the tasks to start") { recorder.events.count == 3 }
        recorder.tasks.cancel("a")
        recorder.tasks.cancel(where: { $0 == "b" })
        assertFalse(recorder.tasks.isRunning("a"))
        assertTrue(recorder.tasks.isRunning("c"))
        recorder.ready = true
        try await waitFrames(3)
        assertEqual(recorder.events.filter { $0.hasSuffix("done") }, ["c done"], "only the remaining task finished")
        assertFalse(recorder.tasks.isRunning("c"), "a finished task is no longer running")
        try await dispose(owner)
    }

    @GodotMainActor
    public func testWaitsPauseWithTheOwner() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        owner.processMode = .disabled
        recorder.startWaiting()
        try await waitFrames(3)
        assertEqual(recorder.events, [], "doesn't start while the owner can't process")
        owner.processMode = .inherit
        try await waitUntil("the task to start") { recorder.events.count == 1 }

        owner.processMode = .disabled
        recorder.ready = true
        try await waitFrames(3)
        assertEqual(recorder.events, ["wait started"], "doesn't advance while the owner can't process")
        owner.processMode = .inherit
        try await waitUntil("the task to finish") { recorder.events.count == 2 }
        try await dispose(owner)
    }

    @GodotMainActor
    public func testWaitsPauseOutsideTheTree() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        owner.getParent()?.removeChild(node: owner)
        recorder.startWaiting()
        try await waitFrames(3)
        assertEqual(recorder.events, [], "doesn't start outside the tree")
        (Engine.getMainLoop() as? SceneTree)?.root.addChild(node: owner)
        try await waitUntil("the task to start once in the tree") { recorder.events.count == 1 }
        try await dispose(owner)
    }

    @GodotMainActor
    public func testFreeingTheOwnerEndsTheTask() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startWaiting()
        try await waitUntil("the task to start") { recorder.events.count == 1 }
        owner.queueFree()
        try await waitFrames(2)
        assertFalse(recorder.tasks.isRunning("wait"), "freeing the owner cancelled the task")
        recorder.ready = true
        try await waitFrames(3)
        assertEqual(recorder.events, ["wait started"], "the rest of the task didn't run")
    }

    /// The case polling the owner each frame cannot catch: a task suspended on another
    /// object's signal.  Freeing the owner must cancel it at once and disconnect, rather than
    /// leave it to run on a freed node whenever the signal fires.
    @GodotMainActor
    public func testFreeingTheOwnerEndsATaskWaitingOnAnotherObjectsSignal() async throws {
        let owner = try makeOwner()
        let other = Node()
        let recorder = TaskRecorder(owner: owner)
        recorder.startAwaitingRename(of: other)
        try await waitUntil("the task to connect") {
            other.getSignalConnectionList(signal: "renamed").count == 1
        }
        owner.queueFree()
        try await waitFrames(1)
        assertFalse(recorder.tasks.isRunning("signal"), "freeing the owner cancelled the task")
        assertEqual(other.getSignalConnectionList(signal: "renamed").count, 0, "the cancelled await disconnected")
        other.renamed.emit()
        try await waitFrames(2)
        assertEqual(recorder.events, ["signal started"], "the rest of the task didn't run")
        other.queueFree()
    }

    /// `frames.wait(for:)` holds the task back while its owner can't process.
    @GodotMainActor
    public func testSignalWaitsPauseWithTheOwner() async throws {
        let owner = try makeOwner()
        let other = Node()
        let recorder = TaskRecorder(owner: owner)
        recorder.startAwaitingRename(of: other)
        try await waitUntil("the task to connect") {
            other.getSignalConnectionList(signal: "renamed").count == 1
        }
        owner.processMode = .disabled
        other.renamed.emit()
        try await waitFrames(3)
        assertEqual(recorder.events, ["signal started"], "doesn't continue while the owner can't process")
        owner.processMode = .inherit
        try await waitUntil("the task to finish") { recorder.events.count == 2 }
        other.queueFree()
        try await dispose(owner)
    }

    @GodotMainActor
    public func testWaitSecondsTakesThatLong() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        let start = Time.getTicksMsec()
        recorder.startTimer(seconds: 0.25)
        try await waitFrames(2)
        assertEqual(recorder.events, [], "not done after two frames")
        try await waitUntil(frames: 600, "the timer") { recorder.events == ["timer done"] }
        assertGreaterThanOrEqual(Time.getTicksMsec() - start, 200, "took about the time asked for")
        try await dispose(owner)
    }

    @GodotMainActor
    public func testAFailingTaskEnds() async throws {
        let owner = try makeOwner()
        let recorder = TaskRecorder(owner: owner)
        recorder.startFailing()
        try await waitFrames(2)
        assertFalse(recorder.tasks.isRunning("boom"))
        try await dispose(owner)
    }
}
