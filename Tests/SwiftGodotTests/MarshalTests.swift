import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
private class TestNode: Node {
    @Export
    var closure: (Int, Int, Int) -> Int = { (a: Int, b: Int, c: Int) -> Int in
        return a + b + c
    }
    
    @Callable
    func double(_ ints: [Int]) -> [Double] {
        return ints.map {
            Double($0) * 2.0
        }
    }
    
    
    @Callable
    func foo(_ callable: Callable, a: Int, b: Int) -> Int {
        guard let variant = callable.call(Variant(a), Variant(b)) else {
            return -1
        }
        
        guard let value = Int(variant) else {
            return -1
        }
        
        return value
    }
    
    @Callable
    func bar(_ value: Variant?) -> Variant? {
        return value
    }
}

final class MarshalTests: GodotTestCase {
    
    override static var godotSubclasses: [Wrapped.Type] {
        return [TestNode.self]
    }
    
    func testExportedClosure() {
        let node = TestNode()
        
        guard let callable = node.call(method: "get_closure").map({ Callable.fromVariant($0) }) as? Callable else {
            XCTFail()
            return
        }
        
        guard let result = callable.call(1.toVariant(), 2.toVariant(), 3.toVariant()).to(Int.self) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(6, result)
        
        _ = node.call(method: "set_closure", Callable { arguments in
            do {
                var value = try arguments.argument(ofType: Int.self, at: 0)
                value *= try arguments.argument(ofType: Int.self, at: 1)
                value *= try arguments.argument(ofType: Int.self, at: 2)
                return value.toVariant()
            } catch {
                return nil
            }
        }.toVariant())
        
        XCTAssertEqual(node.closure(2, 3, 4), 24)
        
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
    
    func testCallableArgumentInCallable() {
        let testNode = TestNode()
        
        let result = testNode.foo(Callable({ arguments in
            do {
                let a = try arguments.argument(ofType: Int.self, at: 0)
                let b = try arguments.argument(ofType: Int.self, at: 1)
                return (a * b).toVariant()
            } catch {
                return nil
            }
        }), a: 11, b: 6)
        
        XCTAssertTrue(result == 66)
        
        let anotherResult = testNode.call(
            method: "foo",
            Callable({ arguments in
                do {
                    let a = try arguments.argument(ofType: Int.self, at: 0)
                    let b = try arguments.argument(ofType: Int.self, at: 1)
                    return (a - b).toVariant()
                } catch {
                    return nil
                }
            }).toVariant(),
            55.toVariant(),
            22.toVariant(),
        ).to(Int.self)
        
        XCTAssertEqual(anotherResult, 33)
    }
    
    func testSwiftArrays() {
        let testNode = TestNode()
        let array = GArray(Int.self)
        array.append(Variant(20))
        array.append(Variant(40))
        
        guard let variant = testNode.call(method: "double", array.toVariant()) else {
            XCTFail()
            return
        }
        
        guard let collection = VariantCollection<Double>(variant) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(collection[0], 40.0)
        XCTAssertEqual(collection[1], 80.0)
        
    }
    
    func testCallableMethodReturningVariant() {
        let testNode = TestNode()
        
        XCTAssertEqual(testNode.call(method: "bar", Variant(42)), Variant(42))
        XCTAssertEqual(testNode.call(method: "bar", Variant("Foo")), Variant("Foo"))
        XCTAssertEqual(testNode.call(method: "bar", nil), nil)
    }
    
    func testUnsafePointersNMemoryLayout() {
        // UnsafeRawPointersN# is keeping `UnsafeRawPointer?` inside, but Swift Compiler is smart enough to confine the optionality of `UnsafeRawPointer` as a property of its payload (being a zero address or not) instead of introducing an extra byte and consequential alignment padding.
        XCTAssertEqual(MemoryLayout<UnsafeRawPointersN9>.size, MemoryLayout<UnsafeRawPointer>.stride * 9, "UnsafeRawPointersN should have the same size as a N of UnsafeRawPointers")
    }
    
    func testVariants () {
        let dc = Double.pi
        
        XCTAssertEqual (1, Int.fromVariant(1.toVariant()))
        XCTAssertEqual ("The Dog", String.fromVariant("The Dog".toVariant()))
        XCTAssertEqual(dc, Double.fromVariant(dc.toVariant()))
        XCTAssertEqual(true, Bool.fromVariant(true.toVariant()))
        XCTAssertEqual(false, Bool.fromVariant(false.toVariant()))
        XCTAssertEqual(2.toVariant(), 2.toVariant())
    }
    
    func testCallableViaSwiftClosure() {
        var callable = Callable { (a: Int, b: Int, c: String) -> String in
            return [String](repeating: c, count: a + b).joined(separator: " ")
        }
        
        var result = callable.call(
            1.toVariant(),
            2.toVariant(),
            "Amazing!".toVariant()
        )
                
        XCTAssertEqual(result.to(String.self), "Amazing! Amazing! Amazing!")
        
        callable = Callable { (yes: Bool, ifYes: String, array: VariantCollection<String>) -> String in
            yes ? ifYes : array.joined(separator: " ")
        }
        
        let collection: VariantCollection<String> = [
            "Never", "Gonna", "Give", "You", "Up"
        ]
        
        result = callable.call(
            true.toVariant(),
            "YES!".toVariant(),
            collection.toVariant(),
        )
                
        XCTAssertEqual(result.to(String.self), "YES!")
        
        result = callable.call(
            false.toVariant(),
            "Whatever".toVariant(),
            collection.toVariant(),
        )
                
        XCTAssertEqual(result.to(String.self), "Never Gonna Give You Up")
        
        result = callable.call(
            false.toVariant(),
            "Whatever".toVariant(),
        )
        
        // Wrong parameters logged
        XCTAssertEqual(result, nil)
        
        
        callable = Callable { (a: Int, b: Int) in
             GD.print(a + b)
         }
        
        _ = callable.call(
            1.toVariant(),
            2.toVariant(),
        )
    }
}

