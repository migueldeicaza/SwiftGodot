
@testable import SwiftGodot

@Godot
private class TestSignalNode: Node {
    #signal("mySignal", arguments: ["age": Int.self, "name": String.self])
    @Signal var nuSignal: SignalWithArguments<Int, String>
    var receivedInt: Int? = nil
    var receivedString: String? = nil
    
    @Callable func receiveSignal (_ age: Int, name: String) {
        receivedInt = age
        receivedString = name
    }

    override func _validateProperty(_ prop: inout PropInfo) -> Bool {

        return true
    }
}

@SwiftGodotTestSuite
final class SignalTests {
    public static var registeredTypes: [Object.Type] {
        return [TestSignalNode.self]
    }

    public func testUserDefinedSignal() {
        let node = TestSignalNode()

        node.connect (signal: TestSignalNode.mySignal, to: node, method: "receiveSignal")
        node.emit (signal: TestSignalNode.mySignal, 22, "Joey")

        assertEqual (node.receivedInt, 22, "Integers should have been the same")
        assertEqual (node.receivedString, "Joey", "Strings should have been the same")
        node.queueFree()
    }

    public func testNuSignal() {
        let node = TestSignalNode()
        var signalReceived = false

        node.nuSignal.connect { age, name in
            assertEqual (age, 22)
            assertEqual (name, "Sam")
            signalReceived = true
        }
        node.nuSignal.emit(22, "Sam")
        assertTrue (signalReceived, "signal should have been received")
        node.queueFree()
    }

    public func testBuiltInSignalWithNoArgument() {
        let node = Node()
        var signalReceived = false
        node.ready.connect {
            signalReceived = true
        }
        node.ready.emit()
        assertTrue (signalReceived, "signal should have been received")
        node.queueFree()
    }

    public func testBuiltInSignalWithArgument() {
        let node = Node()
        var signalReceived = false
        node.childExitingTree.connect { (nodeParameter: Node?) in // full signature is specified here to check that it's being generated with the right types
            signalReceived = true
            assertEqual(node, nodeParameter)
        }
        node.childExitingTree.emit(node)
        assertTrue (signalReceived, "signal should have been received")
        node.queueFree()
    }

    public func testBuiltInSignalWithPrimitiveArguments() {
        let node = AnimationNode()
        var signalReceived = false
        node.animationNodeRenamed.connect { (id: Int64, oldName: String, newName: String) in  // full signature is specified here to check that it's being generated with the right types
            signalReceived = true
            assertEqual(id, 123)
            assertEqual(oldName, "old name")
            assertEqual(newName, "new name")
        }
        node.animationNodeRenamed.emit(123, "old name", "new name")
        assertTrue (signalReceived, "signal should have been received")
        // AnimationNode is a Resource (reference-counted) — no manual free needed.
    }

    // MARK: - Awaiting signals
    //
    // These run on `GodotMainActor`, whose executor is Godot's message queue, so every
    // call below happens on Godot's main thread.
    //
    // The emission is always posted with `callDeferred` rather than called inline. The
    // await connects synchronously and only then suspends, so a deferred emission is
    // guaranteed to land after the connection exists — which is the ordering these tests
    // need and the reason they are not racy.

    @GodotMainActor
    public func testAwaitSignalDeliversPayload() async throws {
        let node = TestSignalNode()
        defer { node.queueFree() }

        emitLater { node.nuSignal.emit(22, "Sam") }

        let (age, name) = try await node.nuSignal.emitted
        assertEqual(age, 22)
        assertEqual(name, "Sam")
    }

    @GodotMainActor
    public func testAwaitSimpleSignalReturnsVoid() async throws {
        let node = Node()
        defer { node.queueFree() }

        emitLater { node.ready.emit() }

        // A SimpleSignal has an empty argument pack, so the payload type is `()`.
        try await node.ready.emitted
    }

    @GodotMainActor
    public func testAwaitSignalWithOneArgumentIsNotATuple() async throws {
        let node = Node()
        defer { node.queueFree() }

        emitLater { node.childExitingTree.emit(node) }

        // A one-element pack collapses to the value itself, not a 1-tuple.
        let child: Node? = try await node.childExitingTree.emitted
        assertEqual(child, node)
    }

    /// Cancelling the awaiting task must throw *and* drop the Godot-side connection.
    /// This is the regression test for the leak that got `emitted` deprecated.
    @GodotMainActor
    public func testAwaitSignalCancellationDisconnects() async throws {
        let node = TestSignalNode()
        defer { node.queueFree() }

        let signalName = StringName("nu_signal")
        assertEqual(node.getSignalConnectionList(signal: signalName).count, 0,
                    "no connections before awaiting")

        let task = Task { @GodotMainActor in
            try await node.nuSignal.emitted
        }

        // Let the task reach its suspension point. Both this test and the task run on
        // GodotMainActor, which drains in order, so one hop is enough.
        await Task.yield()
        assertEqual(node.getSignalConnectionList(signal: signalName).count, 1,
                    "awaiting should have connected")

        task.cancel()

        do {
            _ = try await task.value
            fail("cancelled await should have thrown")
        } catch is CancellationError {
            // expected
        } catch {
            fail("expected CancellationError, got \(error)")
        }

        assertEqual(node.getSignalConnectionList(signal: signalName).count, 0,
                    "cancelling should have disconnected")
    }

    /// A signal whose declaring object is already gone reports it instead of hanging.
    @GodotMainActor
    public func testAwaitSignalWithMissingTargetThrows() async throws {
        // SignalWithArguments holds its target weakly, so letting the only reference go
        // leaves a signal handle with nothing behind it.
        var signal: SimpleSignal?
        do {
            let owner = RefCounted()
            signal = SimpleSignal(target: owner, signalName: "script_changed")
        }

        guard let signal else {
            fail("signal was not created")
            return
        }

        do {
            try await signal.emitted
            fail("awaiting a signal with no target should have thrown")
        } catch SignalAwaitError.targetUnavailable {
            // expected
        } catch {
            fail("expected .targetUnavailable, got \(error)")
        }
    }

    /// The builtin `Signal` Variant type — what you get from GDScript or
    /// `Signal(object:signal:)` — is awaitable too, with an untyped payload.
    @GodotMainActor
    public func testAwaitBuiltinSignalValue() async throws {
        let node = TestSignalNode()
        defer { node.queueFree() }

        let signal = Signal(object: node, signal: "nu_signal")
        emitLater { node.nuSignal.emit(7, "Robin") }

        let arguments = try await signal.emitted
        assertEqual(arguments.count, 2)
        assertEqual(arguments.first??.to(Int.self), 7)
        assertEqual(arguments.last??.to(String.self), "Robin")
    }
}

