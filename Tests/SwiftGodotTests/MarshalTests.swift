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

