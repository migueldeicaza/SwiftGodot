import SwiftGodot
import SwiftGodotTestMacros

#if DEBUG
@testable import SwiftGodotRuntime

@SwiftGodotTestSuite
final class SignalAwaiterTests {
    /// Cancellation occurs after begin(), while Godot sets up the connection.
    /// The token must remain available when the caller resumes to disconnect.
    @GodotMainActor
    public func testTypedCancellationDuringConnectionSetup() async {
        let owner = Object()
        defer { owner.free() }
        let token = Callable { (_: borrowing Arguments) -> Variant? in nil }
        let signalName = StringName("script_changed")
        let awaiter = SignalAwaiter<Int>()

        do {
            let _: Int = try await withCheckedThrowingContinuation { continuation in
                assertTrue(awaiter.begin(continuation))
                awaiter.cancel()
                assertEqual(owner.connect(signal: signalName, callable: token,
                    flags: UInt32(Object.ConnectFlags.oneShot.rawValue)), .ok)
                awaiter.connected(token)
            }
            fail("cancelled await should throw")
        } catch is CancellationError {
            guard let cleanupToken = awaiter.takeToken() else {
                fail("cancellation during setup lost the connection token")
                return
            }
            owner.disconnect(signal: signalName, callable: cleanupToken)
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
        let token = Callable { (_: borrowing Arguments) -> Variant? in nil }
        let awaiter = VariantSignalAwaiter()

        do {
            let _: [Variant?] = try await withCheckedThrowingContinuation { continuation in
                assertTrue(awaiter.begin(continuation))
                awaiter.cancel()
                assertEqual(signal.connect(callable: token,
                    flags: Int64(Object.ConnectFlags.oneShot.rawValue)), GodotError.ok.rawValue)
                awaiter.connected(token)
            }
            fail("cancelled await should throw")
        } catch is CancellationError {
            guard let cleanupToken = awaiter.takeToken() else {
                fail("cancellation during setup lost the connection token")
                return
            }
            signal.disconnect(callable: cleanupToken)
            assertFalse(signal.isConnected(callable: token))
        } catch {
            fail("expected CancellationError, got \(error)")
        }
    }
}
#else
// The suite scanner also reads inactive branches. Keep an empty suite for release
// builds, where the runtime does not expose internal declarations to tests.
final class SignalAwaiterTests: SwiftGodotTestSuiteProtocol {
    var allTests: [SwiftGodotTestInvocation] { [] }
}
#endif
