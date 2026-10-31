//
//  GodotMainActor.swift
//  SwiftGodot
//
//  A global actor whose executor is Godot's main thread, on every platform.
//
//  Swift's `MainActor` runs on the process's main dispatch queue. This is not guaranteed
//  to be the same as Godot's main thread and in fact it often is not. Therefore `MainActor`
//  jobs can run on a thread other than Godot's where touching the scene tree races the engine.
//  `GodotMainActor` exists to address this by guaranteeing code is scheduled on
//  Godot's main thread on every platform, and works even with custom MainLoops.
//

import Foundation
import GDExtension

/// The global actor for code that must run on Godot's main thread.
///
/// Its jobs run at the start of each frame, from `SceneTree`'s `process_frame` signal,
/// before any node's `_process`.  Nothing has to be set up: on Godot 4.5 and later the
/// main loop's startup callback starts the executor, and on earlier versions the first job
/// queued does.
///
/// ```swift
/// @Callable
/// func openDoor() {
///     Task { @GodotMainActor in
///         try await door.animationFinished.emitted
///         door.collision.disabled = true
///     }
/// }
/// ```
///
/// From synchronous code that Godot calls on its main thread, such as `_process` or a
/// signal callback, use `GodotMainActor.assumeIsolated { ... }` to call isolated code directly.
///
/// For waits measured in frames or seconds, and for tasks that follow a node's lifetime,
/// see `GodotFrames` and `GodotTasks`.
@globalActor
public actor GodotMainActor {
    public static let shared = GodotMainActor()

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        GodotMainActorExecutor.shared.asUnownedSerialExecutor()
    }

    /// Runs `operation` synchronously, isolated to `GodotMainActor`, when called on Godot's
    /// main thread.  Traps anywhere else.
    public static func assumeIsolated<T>(
        _ operation: @GodotMainActor () throws -> T,
        file: StaticString = #fileID,
        line: UInt = #line
    ) rethrows -> T {
        guard GodotMainActorExecutor.shared.isOnGodotMainThread else {
            fatalError("GodotMainActor.assumeIsolated called off Godot's main thread", file: file, line: line)
        }
        return try withoutActuallyEscaping(operation) { operation in
            try unsafeBitCast(operation, to: (() throws -> T).self)()
        }
    }
}

/// Hooks for the `SwiftGodot` target's `GodotFrames` and `GodotTasks`.  They need `Node`
/// and `SceneTree`, which are generated into `SwiftGodot`, not this runtime module, so
/// they live there and plug into the executor through these.
@_spi(SwiftGodotRuntimePrivate)
public enum GodotMainActorHooks {
    /// Sets the handlers called on the main thread at the start of each frame, before
    /// queued jobs run, and when the engine shuts down, before the final drain.
    public static func install(frameStarted: @escaping () -> Void, shuttingDown: @escaping () -> Void) {
        GodotMainActorExecutor.shared.setHooks(frameStarted: frameStarted, shuttingDown: shuttingDown)
    }

    /// Records a continuation about to be resumed whose task will continue on
    /// `GodotMainActor`.  The frame's drain waits for it to arrive, rather than letting it slip
    /// to the next frame.  Balance with ``arrived()`` once the task runs.
    public static func willResume() {
        GodotMainActorExecutor.shared.willResume()
    }

    /// Called by the resumed task once it runs on `GodotMainActor` again.
    public static func arrived() {
        GodotMainActorExecutor.shared.arrived()
    }
}

/// Queues jobs from any thread and runs them on Godot's main thread.
final class GodotMainActorExecutor: SerialExecutor, @unchecked Sendable {
    static let shared = GodotMainActorExecutor()

    /// How long a drain waits for resumed tasks still on their way to this executor.
    static let arrivalTimeout: TimeInterval = 0.02

    private enum PumpState {
        /// No pump; the next job requests one.
        case none
        /// A deferred call to install the pump is queued.
        case requested
        /// Draining from `process_frame`, or from the main loop's frame callback when the
        /// main loop is not a `SceneTree`.
        case installed
        /// The engine is shutting down; nothing is drained any more.
        case shutDown
    }

    /// Guards every property below, and wakes a drain waiting for jobs to arrive.
    private let condition = NSCondition()
    private var jobs: [UnownedJob] = []
    private var inFlight = 0
    private var pumpState = PumpState.none
    private var isDraining = false
    private var frameStartedHook: (() -> Void)?
    private var shuttingDownHook: (() -> Void)?

    // Main thread only
    private var pumpCallable: Callable?
    private var pumpTarget: Object?
    private var drainsFromTree = false
    nonisolated(unsafe) private var mainThread: Thread?

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        condition.lock()
        jobs.append(unownedJob)
        let requestPump = pumpState == .none
        if requestPump {
            pumpState = .requested
        }
        condition.signal()
        condition.unlock()

        // Deferred calls are safe to queue from any thread, until the engine starts to
        // delete its message queue.
        if requestPump && canDeferRelease {
            Callable { _ in
                GodotMainActorExecutor.shared.installPump()
                return nil
            }.callDeferred()
        }
    }

    func setHooks(frameStarted: @escaping () -> Void, shuttingDown: @escaping () -> Void) {
        condition.lock()
        frameStartedHook = frameStarted
        shuttingDownHook = shuttingDown
        condition.unlock()
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    func recordMainThread() {
        mainThread = Thread.current
    }

    var isOnGodotMainThread: Bool {
        guard let mainThread else { return false }
        return Thread.current === mainThread
    }

    func checkIsolated() {
        precondition(isOnGodotMainThread, "Expected to be on Godot's main thread, isolated to GodotMainActor")
    }

    func isIsolatingCurrentContext() -> Bool? {
        isOnGodotMainThread
    }

    // MARK: Pump

    /// Starts draining every frame.  Called on the main thread: from the main loop's startup
    /// callback on Godot 4.5 and later, or else from a deferred call queued by the first job.
    /// The deferred call also reinstalls the pump after ``uninstallPump()``.
    func installPump() {
        condition.lock()
        let state = pumpState
        if state == .none || state == .requested {
            pumpState = .installed
        }
        condition.unlock()
        guard state == .none || state == .requested else { return }

        mainThread = Thread.current
        if let loop = Engine.getMainLoop() {
            let callable = Callable { _ in
                GodotMainActorExecutor.shared.frame()
                return nil
            }
            // `process_frame` is SceneTree's.  A custom MainLoop does not have it, and is
            // drained from the main loop's frame callback instead.
            if loop.hasSignal("process_frame"), loop.connect(signal: "process_frame", callable: callable) == .ok {
                pumpCallable = callable
                pumpTarget = loop
                drainsFromTree = true
            }
        }
        if !drainsFromTree && gi.register_main_loop_callbacks == nil {
            GD.printErr("GodotMainActor: the main loop has no process_frame signal, and this Godot has no main loop callbacks; tasks will not run")
        }
        drain()
    }

    /// Stops draining from `process_frame`, so the connection does not outlive this
    /// extension.  The next job installs the pump again.
    func uninstallPump() {
        if let pumpTarget, let pumpCallable, pumpTarget.isConnected(signal: "process_frame", callable: pumpCallable) {
            pumpTarget.disconnect(signal: "process_frame", callable: pumpCallable)
        }
        pumpTarget = nil
        pumpCallable = nil
        drainsFromTree = false
        condition.lock()
        if pumpState == .installed {
            pumpState = .none
        }
        condition.unlock()
    }

    /// The main loop's per-frame callback.  It runs after every `_process`, so it only
    /// drains when `process_frame`, which runs before them, is not available.
    func mainLoopFrame() {
        guard !drainsFromTree else { return }
        condition.lock()
        let installed = pumpState == .installed
        condition.unlock()
        if installed {
            frame()
        }
    }

    /// Cancels and runs down what is left while the engine is still fully up, so no task is
    /// left suspended on, or resumed into, a dying engine.
    func shutDown() {
        condition.lock()
        let wasShutDown = pumpState == .shutDown
        let hook = shuttingDownHook
        condition.unlock()
        guard !wasShutDown else { return }

        hook?()
        drain()
        uninstallPump()
        condition.lock()
        pumpState = .shutDown
        condition.unlock()
    }

    private func frame() {
        condition.lock()
        let hook = frameStartedHook
        condition.unlock()
        hook?()
        drain()
    }

    // MARK: Draining

    func willResume() {
        condition.lock()
        inFlight += 1
        condition.unlock()
    }

    func arrived() {
        condition.lock()
        inFlight -= 1
        condition.signal()
        condition.unlock()
    }

    /// Runs queued jobs, including any they queue in turn, until there are none left and no
    /// resumed task is still on its way here.
    ///
    /// A resumed continuation does not always come straight to this executor. The runtime
    /// can run it on the global executor first, which then switches to this one from a
    /// worker thread, usually within microseconds.  Finishing the drain before it arrives
    /// would run the task a frame late, after nodes have processed, so the drain waits for
    /// the resumes it was told about (``GodotMainActorHooks/willResume()``), up to
    /// ``arrivalTimeout``.
    func drain() {
        condition.lock()
        guard !isDraining, pumpState != .shutDown else {
            condition.unlock()
            return
        }
        isDraining = true
        var deadline: Date? = nil
        while true {
            if jobs.isEmpty {
                guard inFlight > 0 else { break }
                let waitUntil = deadline ?? Date(timeIntervalSinceNow: Self.arrivalTimeout)
                deadline = waitUntil
                if !condition.wait(until: waitUntil) && jobs.isEmpty {
                    GD.printErr("GodotMainActor: resumed tasks did not arrive within \(Int(Self.arrivalTimeout * 1000)) ms; they will run next frame")
                    break
                }
                continue
            }
            let batch = jobs
            jobs.removeAll(keepingCapacity: true)
            condition.unlock()
            for job in batch {
                job.runSynchronously(on: asUnownedSerialExecutor())
            }
            condition.lock()
        }
        isDraining = false
        condition.unlock()
    }
}

// MARK: Main loop callbacks

/// Called from the extension's entry point, which Godot runs on its main thread. We record
/// that thread, and register the main loop callbacks for `library` on Godot 4.5 and later.
func prepareGodotMainActor(library: UnsafeMutableRawPointer) {
    GodotMainActorExecutor.shared.recordMainThread()
    guard let register = gi.register_main_loop_callbacks else { return }
    var callbacks = GDExtensionMainLoopCallbacks(
        startup_func: godotMainActorMainLoopStartup,
        shutdown_func: godotMainActorMainLoopShutdown,
        frame_func: godotMainActorMainLoopFrame)
    register(library, &callbacks)
}

private func godotMainActorMainLoopStartup() {
    GodotMainActorExecutor.shared.installPump()
}

private func godotMainActorMainLoopShutdown() {
    GodotMainActorExecutor.shared.shutDown()
}

private func godotMainActorMainLoopFrame() {
    GodotMainActorExecutor.shared.mainLoopFrame()
}
