import Foundation
@_implementationOnly import GDExtension

public extension RefCounted {
    /// Decrements the internal reference counter. Deletes underlying object if it goes to zero..
    /// 
    /// This is flagged `_exp` because it will eventually be folded into deinit for RefCounted
    /// objects
    func _exp_unref() {
        let instanceID = Int64(bitPattern: UInt64(getInstanceId()))
        if GD.isInstanceIdValid(id: instanceID) {
            if unreference() {
                gi.object_destroy(UnsafeMutableRawPointer(mutating: handle))
            }
        }
    }
}

#if !canImport(Darwin)
///
/// Installs a callback into Godot engine on non-Darwin platforms, which don't typically have a run-loop.
/// Creates a 10 Hz timer that gives time back to the Godot main loop, so that XCTest can use blocking sub-runloops
/// to wait for expectations to be fulfilled, which is the basis for the async versions of tests.
/// This mechanism avoids hangs using this bi-directional callback approach.
/// This code is currently in the SwiftGodot package because it needs to make calls into
/// GodotInterface functions.
/// 
public extension RunLoop {
    static var in_runloop_count: Int = 0

    static func install() {
        gi.displayserver_set_runloop {
            RunLoop.in_runloop_count += 1
            RunLoop.main.run(until: .now)
            RunLoop.in_runloop_count -= 1
        }
        let timer = Foundation.Timer(timeInterval: 0.1, repeats: true) { _ in
            if RunLoop.in_runloop_count > 0 {
                gi.main_iteration()
            }
        }
        RunLoop.main.add(timer, forMode: .default)
    }
}
#endif
