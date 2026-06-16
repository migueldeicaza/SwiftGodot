
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
}

