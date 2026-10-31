//
//  EmitLater.swift
//  SwiftGodotTestExtension
//

import SwiftGodot

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
