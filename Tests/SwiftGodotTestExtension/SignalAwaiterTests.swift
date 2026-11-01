import SwiftGodot
import SwiftGodotTestMacros

#if DEBUG
@testable import SwiftGodotRuntime

@SwiftGodotTestSuite
final class SignalAwaiterTests {
    /// Cancellation occurs after begin(), while Godot sets up the connection.
    /// The connection must remain available when the caller resumes to disconnect.
    @GodotMainActor
    public func testTypedCancellationDuringConnectionSetup() async {
        let owner = Object()
        defer { owner.free() }
        let signalName = StringName("script_changed")
        let awaiter = OneShotAwaiter<Int>()

        do {
            let _: Int = try await withCheckedThrowingContinuation { continuation in
                assertTrue(awaiter.begin(continuation))
                awaiter.cancel()
                let connection = OneShotConnection {}
                assertEqual(owner.connect(signal: signalName, callable: connection.makeCallable { _ in },
                    flags: UInt32(Object.ConnectFlags.oneShot.rawValue)), .ok)
                awaiter.connected(connection)
            }
            fail("cancelled await should throw")
        } catch is CancellationError {
            guard let connection = awaiter.takeConnection() else {
                fail("cancellation during setup lost the connection")
                return
            }
            owner.disconnect(signal: signalName, callable: connection.makeCallable { _ in })
            assertEqual(owner.getSignalConnectionList(signal: signalName).count, 0)
        } catch {
            fail("expected CancellationError, got \(error)")
        }
    }

    @GodotMainActor
    public func testBuiltinCancellationDuringConnectionSetup() async {
        let owner = Object()
        defer { owner.free() }
        let signal = Signal(object: owner, signal: "script_changed")
        let awaiter = OneShotAwaiter<[Variant?]>()

        do {
            let _: [Variant?] = try await withCheckedThrowingContinuation { continuation in
                assertTrue(awaiter.begin(continuation))
                awaiter.cancel()
                let connection = OneShotConnection {}
                assertEqual(signal.connect(callable: connection.makeCallable { _ in },
                    flags: Int64(Object.ConnectFlags.oneShot.rawValue)), GodotError.ok.rawValue)
                awaiter.connected(connection)
            }
            fail("cancelled await should throw")
        } catch is CancellationError {
            guard let connection = awaiter.takeConnection() else {
                fail("cancellation during setup lost the connection")
                return
            }
            signal.disconnect(callable: connection.makeCallable { _ in })
            assertEqual(owner.getSignalConnectionList(signal: "script_changed").count, 0)
        } catch {
            fail("expected CancellationError, got \(error)")
        }
    }

    /// Callables made from the same connection compare equal; callables made from
    /// different connections do not.  Disconnecting on cancellation depends on this.
    @GodotMainActor
    public func testConnectionCallablesShareIdentity() {
        let a = OneShotConnection {}
        let b = OneShotConnection {}

        assertTrue(a.makeCallable { _ in } == a.makeCallable { _ in })
        assertFalse(a.makeCallable { _ in } == b.makeCallable { _ in })
        assertEqual(a.makeCallable { _ in }.hash(), a.makeCallable { _ in }.hash())
    }

    /// The connection is released - and says so - once Godot drops the last callable that
    /// references it, which is how a freed emitter is noticed.
    @GodotMainActor
    public func testConnectionReportsReleaseWhenGodotDropsIt() {
        let owner = Object()
        var released = false
        do {
            let connection = OneShotConnection { released = true }
            _ = owner.connect(signal: "script_changed", callable: connection.makeCallable { _ in })
        }
        assertFalse(released, "Godot's connection should keep the identity alive")

        owner.free()
        assertTrue(released, "freeing the emitter should release the connection")
    }
}
#else
// The suite scanner also reads inactive branches. Keep an empty suite for release
// builds, where the runtime does not expose internal declarations to tests.
final class SignalAwaiterTests: SwiftGodotTestSuiteProtocol {
    var allTests: [SwiftGodotTestInvocation] { [] }
}
#endif
