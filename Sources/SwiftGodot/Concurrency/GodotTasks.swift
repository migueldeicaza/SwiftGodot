//
//  GodotTasks.swift
//  SwiftGodot
//
//  SwiftGodot implemenation of a named Task for async/await.
//

@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

/// Named tasks on ``GodotMainActor`` that follow an owner node.
///
/// A task first runs at the start of the next frame.  Its ``GodotFrames`` waits only advance on frames the owner has processing enabled.
/// If the owner is freed, the task is immediately cancelled.
/// Running a task under a name that is already running cancels the earlier one.  Cancelled tasks end at their current wait,
/// which throws `CancellationError`that the callsite can react to to unwind cleanly.
///
/// ```swift
/// @Godot
/// class Door: Node3D {
///     lazy var tasks = GodotTasks(owner: self)
///
///     @Callable
///     func open() {
///         tasks.run("Open") { frames in
///             animation.play("open")
///             try await frames.wait(for: animation.animationFinished)
///             try await frames.wait(seconds: 2)
///             animation.play("close")
///         }
///     }
/// }
/// ```
public final class GodotTasks: @unchecked Sendable {
    private struct Entry {
        let token: UInt64
        let task: Task<Void, Never>
    }

    private let owner: FramesOwner
    private let lock = NIOLock()
    private var tasks: [String: Entry] = [:]
    private var freeObservation: ObjectFreeObservation?

    nonisolated(unsafe) private static var live: [ObjectIdentifier: Weak] = [:]
    private static let liveLock = NIOLock()

    private struct Weak {
        weak var tasks: GodotTasks?
    }

    public init(owner: Node) {
        self.owner = FramesOwner(owner)
        freeObservation = ObjectFreeObservers.observe(owner) { [weak self] in
            self?.cancelAll()
        }
        Self.liveLock.withLockVoid {
            Self.live[ObjectIdentifier(self)] = Weak(tasks: self)
        }
    }

    deinit {
        freeObservation?.cancel()
        let id = ObjectIdentifier(self)
        Self.liveLock.withLockVoid {
            _ = Self.live.removeValue(forKey: id)
        }
        cancelAll()
    }

    /// Runs `body` as the task `name`, replacing any task already running under that name.
    public func run(_ name: String, _ body: nonisolated(nonsending) @escaping (GodotFrames) async throws -> Void) {
        cancel(name)
        let token = FrameClock.shared.makeTaskToken()
        let frames = GodotFrames(owner: owner, taskToken: token)
        let owner = owner
        let task = Task { @GodotMainActor [self] in
            do {
                // Start on a frame the owner can process, as its _process would
                if owner.state != .ready {
                    try await frames.next()
                }
                try Task.checkCancellation()
                try await body(frames)
            } catch is CancellationError {
            } catch {
                GD.printErr("Task \"\(name)\" failed: \(error)")
            }
            self.finished(name, token: token)
        }
        lock.withLockVoid {
            tasks[name] = Entry(token: token, task: task)
        }
    }

    /// Whether a task named `name` is running.
    public func isRunning(_ name: String) -> Bool {
        lock.withLock { tasks[name] != nil }
    }

    /// Cancels the task `name`, if one is running.
    public func cancel(_ name: String) {
        cancel { $0 == name }
    }

    /// Cancels every task whose name matches.
    public func cancel(where matches: (String) -> Bool) {
        let removed = lock.withLock { () -> [Entry] in
            let names = tasks.keys.filter(matches)
            return names.compactMap { tasks.removeValue(forKey: $0) }
        }
        for entry in removed {
            entry.task.cancel()
            FrameClock.shared.cancel(taskToken: entry.token)
        }
    }

    /// Cancels every task.
    public func cancelAll() {
        cancel { _ in true }
    }

    private func finished(_ name: String, token: UInt64) {
        lock.withLockVoid {
            if tasks[name]?.token == token {
                tasks.removeValue(forKey: name)
            }
        }
    }

    /// Cancels the tasks of every `GodotTasks`, as the engine shuts down.
    static func cancelEverything() {
        let all = liveLock.withLock { live.values.compactMap(\.tasks) }
        for tasks in all {
            tasks.cancelAll()
        }
    }
}
