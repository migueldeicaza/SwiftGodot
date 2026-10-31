//
//  GodotFrames.swift
//  SwiftGodot
//
//  Support for Async/Awaiting across frames on GodotMainActor.
//  This is the Swift counterpart of GDScript's
//  `await get_tree().process_frame`
//

@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

/// Whether a task's owner lets it advance this frame.
enum OwnerState {
    case ready
    /// Out of the tree, or unable to process (paused, or its process mode disabled).
    case paused
    /// Freed.
    case gone
}

/// The node a `GodotFrames` follows. Checked only on the Godot main thread.
final class FramesOwner: @unchecked Sendable {
    weak var node: Node?

    init(_ node: Node) {
        self.node = node
    }

    var state: OwnerState {
        guard let node, node.handle != nil else { return .gone }
        return node.isInsideTree() && node.canProcess() ? .ready : .paused
    }
}

/// Waiting for a frame, resumed when the owner is able to process.
final class FrameClock: @unchecked Sendable {
    static let shared = FrameClock()

    struct Waiter {
        let owner: FramesOwner?
        /// The `GodotTasks` task waiting, so cancelling it can resume the wait at once.
        let taskToken: UInt64?
        let continuation: CheckedContinuation<Void, any Error>
    }

    private let lock = NIOLock()
    private var nextToken: UInt64 = 0
    private var waiters: [Waiter] = []
    private var lastDelta: Double = 0
    private var lastTicks: UInt?
    private var isShutDown = false

    private init() {
        GodotMainActorHooks.install(
            frameStarted: { FrameClock.shared.tick() },
            shuttingDown: {
                GodotTasks.cancelEverything()
                FrameClock.shared.shutDown()
            })
    }

    /// The process delta of the latest frame.
    var delta: Double {
        lock.withLock { lastDelta }
    }

    func makeTaskToken() -> UInt64 {
        lock.withLock {
            nextToken += 1
            return nextToken
        }
    }

    /// Adds a waiter, or returns `false` once the engine is shutting down.
    func add(_ waiter: Waiter) -> Bool {
        lock.withLock {
            guard !isShutDown else { return false }
            waiters.append(waiter)
            return true
        }
    }

    private func resume(_ waiter: Waiter, throwing error: (any Error)? = nil) {
        GodotMainActorHooks.willResume()
        if let error {
            waiter.continuation.resume(throwing: error)
        } else {
            waiter.continuation.resume()
        }
    }

    /// Resumes a task's waits early, throwing `CancellationError`.
    func cancel(taskToken: UInt64) {
        let removed = lock.withLock { () -> [Waiter] in
            let removed = waiters.filter { $0.taskToken == taskToken }
            waiters.removeAll { $0.taskToken == taskToken }
            return removed
        }
        for waiter in removed {
            resume(waiter, throwing: CancellationError())
        }
    }

    /// Ends every wait with `CancellationError`, and refuses new ones.
    private func shutDown() {
        let waiting = lock.withLock { () -> [Waiter] in
            isShutDown = true
            defer { waiters.removeAll() }
            return waiters
        }
        for waiter in waiting {
            resume(waiter, throwing: CancellationError())
        }
    }

    /// Called on the main thread at the start of each frame.
    private func tick() {
        let delta = frameDelta()
        let waiting = lock.withLock { () -> [Waiter] in
            lastDelta = delta
            defer { waiters.removeAll() }
            return waiters
        }
        guard !waiting.isEmpty else { return }

        var owners: [ObjectIdentifier: OwnerState] = [:]
        var kept: [Waiter] = []
        for waiter in waiting {
            let state: OwnerState
            if let owner = waiter.owner {
                let key = ObjectIdentifier(owner)
                state = owners[key] ?? owner.state
                owners[key] = state
            } else {
                state = .ready
            }
            switch state {
            case .ready:
                resume(waiter)
            case .paused:
                kept.append(waiter)
            case .gone:
                resume(waiter, throwing: CancellationError())
            }
        }
        if !kept.isEmpty {
            lock.withLockVoid { waiters.insert(contentsOf: kept, at: 0) }
        }
    }

    /// The time since the last frame scaled by `Engine.timeScale`.
    private func frameDelta() -> Double {
        if let tree = Engine.getMainLoop() as? SceneTree {
            return tree.root.getProcessDeltaTime()
        }
        let ticks = Time.getTicksUsec()
        defer { lastTicks = ticks }
        guard let lastTicks else { return 0 }
        return Double(ticks &- lastTicks) / 1_000_000 * Double(Engine.timeScale)
    }
}

/// Waits measured in frames, on `GodotMainActor`.
///
/// ```swift
/// let frames = GodotFrames()
/// try await frames.next()
/// try await frames.wait(seconds: 0.5)
/// try await frames.waitUntil { player.isOnFloor() }
/// ```
///
/// Every wait throws `CancellationError` when the task is cancelled, and when the engine
/// shuts down.
public struct GodotFrames: Sendable {
    let owner: FramesOwner?
    let taskToken: UInt64?

    /// Waits that advance every frame.
    public init() {
        owner = nil
        taskToken = nil
    }

    /// Waits that advance only on frames `owner` can process, and throw once it is freed.
    @GodotMainActor
    public init(owner: Node) {
        self.owner = FramesOwner(owner)
        taskToken = nil
    }

    init(owner: FramesOwner, taskToken: UInt64) {
        self.owner = owner
        self.taskToken = taskToken
    }

    /// Suspends until the next frame the owner can process.  The task continues at the
    /// start of that frame, before any node's `_process`.
    @GodotMainActor
    public func next() async throws {
        try Task.checkCancellation()
        let owner = owner
        let taskToken = taskToken
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                let waiter = FrameClock.Waiter(owner: owner, taskToken: taskToken, continuation: continuation)
                if !FrameClock.shared.add(waiter) {
                    // Shutting down: resumed as a frame resume would be, so the balance holds.
                    GodotMainActorHooks.willResume()
                    continuation.resume(throwing: CancellationError())
                }
            }
        } catch {
            GodotMainActorHooks.arrived()
            throw error
        }
        GodotMainActorHooks.arrived()
        // Cancelled after this frame's tick resumed the wait, but before the task ran
        try Task.checkCancellation()
    }

    /// Suspends for `count` frames the owner can process.
    public nonisolated(nonsending) func wait(frames count: Int) async throws {
        for _ in 0 ..< count {
            try await next()
        }
    }

    /// Suspends for `seconds` of process time.  `Engine.timeScale` is applied, and time when the owner is not processing isn't counted.
    public nonisolated(nonsending) func wait(seconds: Double) async throws {
        var elapsed = 0.0
        while elapsed < seconds {
            try await next()
            elapsed += FrameClock.shared.delta
        }
    }

    /// Checks `condition` now, and then once per frame the owner can process, until it is true.
    public nonisolated(nonsending) func waitUntil(_ condition: () -> Bool) async throws {
        try Task.checkCancellation()
        while !condition() {
            try await next()
        }
    }

    /// Waits for one emission of `signal`, then, if the owner cannot process at that
    /// point, for the next frame it can.
    ///
    /// Plain ``SignalWithArguments/emitted`` resumes whatever the owner's state, as
    /// GDScript's `await` does.  This one holds the task back while its node is paused or
    /// out of the tree, as the rest of `GodotFrames` does.
    public nonisolated(nonsending) func wait<each T>(for signal: SignalWithArguments<repeat each T>) async throws -> (repeat each T) {
        let payload = try await signal.emitted
        try await untilOwnerIsReady()
        return payload
    }

    /// Waits for one emission of `signal`, then, if the owner cannot process at that
    /// point, for the next frame it can.  See `wait(for:)`.
    public nonisolated(nonsending) func wait(for signal: Signal) async throws -> [Variant?] {
        let arguments = try await signal.emitted
        try await untilOwnerIsReady()
        return arguments
    }

    @GodotMainActor
    private func untilOwnerIsReady() async throws {
        switch owner?.state ?? .ready {
        case .ready:
            return
        case .paused:
            try await next()
        case .gone:
            throw CancellationError()
        }
    }
}
