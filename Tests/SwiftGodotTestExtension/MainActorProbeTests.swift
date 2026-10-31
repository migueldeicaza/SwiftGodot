//
//  MainActorProbeTests.swift
//  SwiftGodotTestExtension
//
//  Where does `Task { @MainActor in ... }` run inside a GDExtension?
//
//  Swift's `MainActor` is backed by the process's main dispatch queue. Godot runs its own
//  event loop, so which thread services that queue is a property of the host platform:
//
//    - on macOS, Godot's display server pumps `[NSApp nextEventMatchingMask:...]` on
//      Godot's main thread, which drains the main queue there;
//    - on Linux and Windows, MainActor jobs run, but on a thread other than Godot's main
//      thread, where touching the scene tree races the engine.
//
//  That difference is why `GodotMainActor` exists. This probe checks thread identity, not just
//  whether the job ran: a MainActor job that runs on the wrong thread is the dangerous
//  case. It asserts only on macOS, where MainActor is expected to be Godot's main thread,
//  and reports elsewhere.
//

import SwiftGodot
import SwiftGodotTestMacros

/// What a `@MainActor` task observed, if it ever ran.
private final class MainActorObservation: @unchecked Sendable {
    private let lock = NIOLock()
    private var _ran = false
    private var _onGodotMainThread = false

    func record(onGodotMainThread: Bool) {
        lock.withLockVoid {
            _ran = true
            _onGodotMainThread = onGodotMainThread
        }
    }

    var snapshot: (ran: Bool, onGodotMainThread: Bool) {
        lock.withLock { (_ran, _onGodotMainThread) }
    }
}

@SwiftGodotTestSuite
final class MainActorProbeTests {
    @GodotMainActor
    public func testWhereMainActorTasksRunUnderGodot() async throws {
        let observation = MainActorObservation()
        Task { @MainActor in
            observation.record(onGodotMainThread: OS.getThreadCallerId() == OS.getMainThreadId())
        }

        // Real frames, not `Task.yield()`: yields on GodotMainActor all run within one drain,
        // and the main dispatch queue is serviced between frames.
        let frames = GodotFrames()
        for _ in 0 ..< 60 {
            if observation.snapshot.ran { break }
            try await frames.next()
        }

        let result = observation.snapshot
        GD.print("[MainActor probe] platform=\(OS.getName()) ran=\(result.ran) onGodotMainThread=\(result.onGodotMainThread)")

        #if os(macOS)
        assertTrue(result.ran, "MainActor task never ran on macOS")
        assertTrue(result.onGodotMainThread, "MainActor task ran off Godot's main thread on macOS")
        #else
        if result.ran && !result.onGodotMainThread {
            GD.print("[MainActor probe]   MainActor runs on a thread other than Godot's here; use GodotMainActor")
        }
        #endif
    }
}
