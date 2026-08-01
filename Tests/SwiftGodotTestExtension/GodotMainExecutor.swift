//
//  GodotMainExecutor.swift
//  SwiftGodotTestExtension
//
//  A Swift concurrency executor that runs jobs on Godot's main thread.
//
//  Swift's `MainActor` is backed by the libdispatch main queue.  Godot does not drain
//  that queue - it runs its own event loop - so a `Task { @MainActor in ... }` inside a
//  GDExtension is not reliably scheduled, and on Linux and Windows may never run at all.
//
//  Godot's actual main-thread pump is its message queue, flushed at idle time each frame.
//  `Callable.callDeferred()` is the supported way onto it, and the runtime already relies
//  on exactly this to release objects from arbitrary threads (see `Wrapped.deinit`).
//  Building a `SerialExecutor` on top of it gives Swift concurrency a main thread that
//  actually corresponds to Godot's.
//
//  This lives in the test target on purpose.  It is a candidate for promotion into
//  SwiftGodot as a public `@GodotActor` once it has proven itself here; until then the
//  shipping API commits to nothing.
//

import SwiftGodot

/// Runs jobs on Godot's main thread by posting them through the engine's message queue.
final class GodotMainExecutor: SerialExecutor {
    static let shared = GodotMainExecutor()

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let executor = asUnownedSerialExecutor()

        // The message queue copies the Callable, which retains the underlying custom
        // callable and therefore this closure, so the job survives until it is flushed.
        let callable = Callable { (_: borrowing Arguments) -> Variant? in
            unownedJob.runSynchronously(on: executor)
            return nil
        }
        callable.callDeferred()
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

/// Posts `body` to Godot's message queue so it runs at the next idle flush.
///
/// Tests use this to emit a signal *after* the awaiting code has connected. An await
/// connects synchronously and only then suspends, so a deferred emission is guaranteed to
/// land after the connection exists - which is what makes these tests deterministic
/// rather than dependent on thread timing.
@GodotMainActor
func emitLater(_ body: @escaping () -> Void) {
    let callable = Callable { (_: borrowing Arguments) -> Variant? in
        body()
        return nil
    }
    callable.callDeferred()
}

/// Global actor whose executor is Godot's main thread.
///
/// Annotate an async test with `@GodotMainActor` so its body - including every call into
/// Godot - runs where Godot expects it.  Global actor isolation belongs to the method
/// itself, so this holds no matter where the runner awaits it from.
@globalActor
actor GodotMainActor {
    static let shared = GodotMainActor()

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        GodotMainExecutor.shared.asUnownedSerialExecutor()
    }
}
