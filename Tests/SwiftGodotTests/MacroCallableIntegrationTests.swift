//
//  MacroCallableIntegrationTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 12/10/2024.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

@Godot
fileprivate class TestObject: Object {
    @Callable
    func countObjects(_ objects: ObjectCollection<TestObject>) -> Int {
        return objects.count
    }
    
    @Callable
    func countBuiltins(_ builtins: VariantCollection<Int>) -> Int {
        return builtins.count
    }
}

@Godot
fileprivate class TestObject2: TestObject { // for checking inheritance
}

final class MacroCallableIntegrationTests: GodotTestCase {
    
    override static var godotSubclasses: [Wrapped.Type] {
        return [TestObject.self, TestObject2.self]
    }
    
    func testImplicitTypingOfUntypedObjectArray() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = GArray()
        objectsArray.append(nil)
        objectsArray.append(Variant(object0))
        objectsArray.append(Variant(object1))
        objectsArray.append(nil)
        objectsArray.append(Variant(object2))
        objectsArray.append(nil)
        
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), Variant(6))
    }
    
    func testImplicitTypingOfUntypedObjectArrayFailure() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = GArray()
        objectsArray.append(nil)
        objectsArray.append(Variant(object0))
        objectsArray.append(Variant(object1))
        objectsArray.append(nil)
        objectsArray.append(Variant(object2))
        objectsArray.append(nil)
        objectsArray.append(Variant(RefCounted())) // this one causes the failure
        
        // Fails, prints into console and returns nil due to RefCounted not being TestObject
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), nil)
    }
    
    func testExplicitlyTypedObjectArrayGodotSideMismatch() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = GArray(TestObject.self)
        objectsArray.append(nil) // 1
        objectsArray.append(Variant(object0)) // 2
        objectsArray.append(Variant(object1)) // 3
        objectsArray.append(nil) // 4
        objectsArray.append(Variant(object2)) // 5
        objectsArray.append(nil) // 6
        
        // this one won't be added, error is logged from Godot, RefCounted is not TestObject
        objectsArray.append(Variant(RefCounted()))
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), Variant(6))
    }
    
    func testTypedObjectArray() {
        let testObject = TestObject()
        
        let object0 = TestObject2()
        let object1 = TestObject()
        let object2 = TestObject()
        
        let objectsArray = ObjectCollection<TestObject>()
        objectsArray.append(nil) // 1
        objectsArray.append(object0) // 2
        objectsArray.append(object1) // 3
        objectsArray.append(nil) // 4
        objectsArray.append(object2) // 5
        objectsArray.append(nil) // 6
        
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), Variant(6))
    }
    
    func testImplicitlyTypingBuiltinsArray() {
        let testObject = TestObject()
        
        let builtinsArray = GArray()
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
    }
    
    
    func testImplicitTypingOfUntypedBuiltinArrayFailure() {
        let testObject = TestObject()
        
        let array = GArray()
        array.append(nil)
        array.append(Variant(1))
        array.append(Variant(2))
        array.append(nil)
        array.append(Variant(3))
        array.append(nil)
        array.append(Variant(4)) // this one causes the failure
        
        // Fails, prints into console and returns nil due to typed builtin array not allowing nils
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(array)), nil)
    }
    
    func testExplicitlyTypedBuiltinArrayGodotSideMismatch() {
        let testObject = TestObject()
        
        let builtinsArray = GArray(Int.self)
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        // this one won't be added, error is logged from Godot, nil Builtins are not allowed in typed Arrays
        builtinsArray.append(nil)
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
    }
    
    func testExplicitlyTypedBuiltinArray() {
        let testObject = TestObject()
        
        let builtinsArray = VariantCollection<Int>()
        builtinsArray.append(1)
        builtinsArray.append(2)
        builtinsArray.append(3)
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
    }
}
