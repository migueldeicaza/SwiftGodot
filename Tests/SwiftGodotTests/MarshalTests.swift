import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
private class TestVariant: Node {
    #signal("mySignal", arguments: ["age": Int.self, "name": String.self])
    var receivedInt: Int? = nil
    var receivedString: String? = nil
    
    @Callable func demo (_ age: Int, name: String) {
        receivedInt = age
        receivedString = name
    }
    
    func probe () {
        connect (signal: TestVariant.mySignal, to: self, method: "demo")
        emit (signal: TestVariant.mySignal, 22, "Joey")
        
    }
}

final class MarshalTests: GodotTestCase {
    
    override static var godotSubclasses: [Wrapped.Type] {
        return [TestVariant.self]
    }

    func testVarArgs() {
        let tv = TestVariant()
        
        tv.probe ()
        XCTAssertEqual (tv.receivedInt, 22, "Integers should have been the same")
        XCTAssertEqual (tv.receivedString, "Joey", "Strings should have been the same")
    }
    
    func testClassesMethodsPerformance() {
        let tv = TestVariant()
        let child = TestVariant()

        measure {
            for _ in 0..<1_000_000 {
                tv.addChild(node: child)
                tv.removeChild(node: child)
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
        let randomValues = (0..<10).map { _ in Variant(Float.random(in: -1.0...1.0)) }
        
        measure {
            for _ in 0..<100_000 {
                let _ = GD.max(arg1: randomValues[0], arg2: randomValues[1], randomValues[2], randomValues[3], randomValues[4], randomValues[5], randomValues[6], randomValues[7], randomValues[8], randomValues[9])
            }
        }
    }
    
    func testUnsafePointersNMemoryLayout() {
        // UnsafeRawPointersN# is keeping `UnsafeRawPointer?` inside, but Swift Compiler is smart enough to confine the optionality of `UnsafeRawPointer` as a property of its payload (being a zero address or not) instead of introducing an extra byte and consequential alignment padding.
        XCTAssertEqual(MemoryLayout<UnsafeRawPointersN9>.size, MemoryLayout<UnsafeRawPointer>.stride * 9, "UnsafeRawPointersN should have the same size as a N of UnsafeRawPointers")
    }
    
    func testUnsafePointersHelpers() {
        var v0 = 0
        var v1 = 1
        var v2 = 2
        var v3 = 3
        var v4 = 4
        var v5 = 5
        var v6 = 6
        var v7 = 7
        var v8 = 8
        var v9 = 9
        var v10 = 10
        var v11 = 11
        var v12 = 12
        var v13 = 13
        var v14 = 14
        
        withUnsafeArgumentsPointer(&v0, &v1, &v2, &v3, &v4, &v5, &v6) { ptr in
            ptr.withMemoryRebound(to: UnsafePointer<Int>.self, capacity: 7) { reboundPtr in
                for i in 0..<7 {
                    XCTAssertEqual(reboundPtr[i].pointee, i)
                }
            }
        }
        
        withUnsafeArgumentsPointer(&v0, &v1, &v2, &v3) { ptr in
            ptr.withMemoryRebound(to: UnsafePointer<Int>.self, capacity: 4) { reboundPtr in
                for i in 0..<4 {
                    XCTAssertEqual(reboundPtr[i].pointee, i)
                }
            }
        }
        
        withUnsafeArgumentsPointer(&v0, &v1, &v2, &v3, &v4, &v5, &v6, &v7, &v8, &v9, &v10, &v11, &v12, &v13, &v14) { ptr in
            ptr.withMemoryRebound(to: UnsafePointer<Int>.self, capacity: 15) { reboundPtr in
                for i in 0..<15 {
                    XCTAssertEqual(reboundPtr[i].pointee, i)
                }
            }
        }
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

