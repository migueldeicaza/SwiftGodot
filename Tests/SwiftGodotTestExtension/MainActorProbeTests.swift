//
//  MainActorProbeTests.swift
//  SwiftGodotTestExtension
//
//  Does `Task { @MainActor in ... }` actually run inside a GDExtension?
//
//  Swift's `MainActor` is backed by the libdispatch main queue. Godot runs its own event
//  loop, so whether that queue is ever drained is a property of the host platform, not of
//  Swift:
//
//    - on macOS, Godot's display server pumps `[NSApp nextEventMatchingMask:...]`, which
//      spins the run loop, which drains the main queue;
//    - on Linux and Windows, Godot pumps its own loop and libdispatch's main queue is
//      never touched.
//
//  Guidance about `await` in SwiftGodot depends on the answer, so measure it rather than
//  assume it. This probe *reports* and does not fail: a platform where MainActor never
//  runs is a finding to document, not a broken build. The number it prints is what the
//  documentation should be based on.
//

import Foundation
import SwiftGodot

/// Records what a `@MainActor` task observed, if it ever ran.
private final class MainActorObservation {
    private let lock = NSLock()
    private var _ran = false
    private var _wasProcessMainThread = false
    private var _thread: String = "<never ran>"

    func record(thread: String, isProcessMainThread: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _ran = true
        _thread = thread
        _wasProcessMainThread = isProcessMainThread
    }

    var snapshot: (ran: Bool, thread: String, wasProcessMainThread: Bool) {
        lock.lock()
        defer { lock.unlock() }
        return (_ran, _thread, _wasProcessMainThread)
    }
}

@SwiftGodotTestSuite
final class MainActorProbeTests {
    /// Reports whether a `@MainActor` task runs under Godot, and on which thread.
    @GodotMainActor
    public func testWhetherMainActorTasksRunUnderGodot() async throws {
        // This test body runs on GodotMainActor, whose executor is Godot's message queue,
        // so this is Godot's main thread by construction.
        let godotThread = String(describing: Thread.current)
        let godotIsProcessMainThread = Thread.isMainThread

        let observation = MainActorObservation()
        Task { @MainActor in
            observation.record(thread: String(describing: Thread.current),
                               isProcessMainThread: Thread.isMainThread)
        }

        // Give it a generous number of frames to be scheduled. Each yield goes back
        // through Godot's message queue, so this advances real frames rather than
        // spinning.
        for _ in 0 ..< 60 {
            await Task.yield()
            if observation.snapshot.ran { break }
        }

        let result = observation.snapshot

        GD.print("[MainActor probe] platform=\(OS.getName())")
        GD.print("[MainActor probe]   godot main thread: \(godotThread) isMainThread=\(godotIsProcessMainThread)")
        GD.print("[MainActor probe]   MainActor task ran: \(result.ran)")
        if result.ran {
            GD.print("[MainActor probe]   MainActor thread: \(result.thread) isMainThread=\(result.wasProcessMainThread)")
            GD.print("[MainActor probe]   same thread as Godot: \(result.thread == godotThread)")
        } else {
            GD.print("[MainActor probe]   MainActor tasks are NOT scheduled on this platform;")
            GD.print("[MainActor probe]   use a Godot-backed executor instead of @MainActor here.")
        }

        // Deliberately no assertion on `ran`. The point is to record the answer per
        // platform, not to declare one platform's behaviour correct.
    }
}
