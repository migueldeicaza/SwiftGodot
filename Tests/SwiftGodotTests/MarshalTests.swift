import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
private class TestNode: Node {
    #signal("mySignal", arguments: ["age": Int.self, "name": String.self])
    var receivedInt: Int? = nil
    var receivedString: String? = nil
    
    @Callable func demo (_ age: Int, name: String) {
        receivedInt = age
        receivedString = name
    }
    
    func probe () {
        connect (signal: TestNode.mySignal, to: self, method: "demo")
        emit (signal: TestNode.mySignal, 22, "Joey")
        
    }
}

final class MarshalTests: GodotTestCase {
    
    override static var godotSubclasses: [Wrapped.Type] {
        return [TestNode.self]
    }

    func testVarArgs() {
        let node = TestNode()
        
        node.probe ()
        XCTAssertEqual (node.receivedInt, 22, "Integers should have been the same")
        XCTAssertEqual (node.receivedString, "Joey", "Strings should have been the same")
    }
    
    func testClassesMethodsPerformance() {
        let node = TestNode()
        let child = TestNode()

        let addChildName = StringName("add_child")
        let removeChildName = StringName("remove_child")
        let getChildCountName = StringName("get_child_count")
        
        measure {
            for _ in 0..<100_000 {
                node.addChild(node: child)
                XCTAssertEqual(node.getChildCount(), 1)
                node.removeChild(node: child)
                XCTAssertEqual(node.getChildCount(), 0)
                
                _ = node.call(method: addChildName, Variant(child), Variant(false), Variant(Node.InternalMode.disabled.rawValue))
                XCTAssertEqual(node.call(method: getChildCountName), Variant(1))
                _ = node.call(method: removeChildName, Variant(child))
                XCTAssertEqual(node.call(method: getChildCountName), Variant(0))
            }
        }
    }
    
    func testBuiltinsTypesMethodsPerformance() {
        let makeRandomVector = {
            Vector3(x: .random(in: -1.0...1.0), y: .random(in: -1.0...1.0), z: .random(in: -1.0...1.0))
        }
        
        let a = makeRandomVector()
        let b = makeRandomVector()
        let preA = makeRandomVector()
        let preB = makeRandomVector()
        let weight = 0.23
        
        measure {
            for _ in 0..<1_000_000 {
                let _ = a.cubicInterpolate(b: b, preA: preA, postB: preB, weight: weight)
            }
        }
    }
    
    func testVarargMethodsPerformance() {
        let floats = (0..<10).map { _ in Float.random(in: -1.0...1.0) }
        let randomValues = floats.map { Variant($0) }
        
        let max = Variant(floats.max()!)
        
        measure {
            for _ in 0..<100_000 {
                let maxVariant = GD.max(arg1: randomValues[0], arg2: randomValues[1], randomValues[2], randomValues[3], randomValues[4], randomValues[5], randomValues[6], randomValues[7], randomValues[8], randomValues[9])
                XCTAssertEqual(max, maxVariant)
            }
        }
    }
    
    func testUnsafePointersNMemoryLayout() {
        // UnsafeRawPointersN# is keeping `UnsafeRawPointer?` inside, but Swift Compiler is smart enough to confine the optionality of `UnsafeRawPointer` as a property of its payload (being a zero address or not) instead of introducing an extra byte and consequential alignment padding.
        XCTAssertEqual(MemoryLayout<UnsafeRawPointersN9>.size, MemoryLayout<UnsafeRawPointer>.stride * 9, "UnsafeRawPointersN should have the same size as a N of UnsafeRawPointers")
    }
    
    func wrapInt <A: VariantStorable>(_ argument: A) -> Int? {
        Int (.init (argument))
    }

    func wrapString <A: VariantStorable>(_ argument: A) -> String? {
        String (.init (argument))
    }

    func wrapDouble <A: VariantStorable>(_ argument: A) -> Double? {
        Double (.init (argument))
    }
    
    func wrapBool <A: VariantStorable>(_ argument: A) -> Bool? {
        Bool (.init (argument))
    }
    
    func testVariants () {
        let dc = Double.pi
        
        XCTAssertEqual (1, wrapInt (1))
        XCTAssertEqual ("The Dog", wrapString ("The Dog"))
        XCTAssertEqual(dc, wrapDouble (dc))
        XCTAssertEqual(true, wrapBool (true))
        XCTAssertEqual(false, wrapBool (false))
    }
}

