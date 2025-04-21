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
    func countObjects(_ objects: TypedArray<TestObject?>) -> Int {
        return objects.count
    }
    
    @Callable
    func countBuiltins(_ builtins: TypedArray<Int>) -> Int {
        return builtins.count
    }
    
    @Callable
    func countMixed(builtins: TypedArray<Int>, _ objects: TypedArray<RefCounted?>, array: VariantArray, variant: Variant?) -> Int? {
        return builtins.count + objects.count + array.count
    }
}

@Godot
fileprivate class TestObject2: TestObject { // for checking inheritance
}

final class MacroCallableIntegrationTests: GodotTestCase {
    
    override static var godotSubclasses: [Object.Type] {
        return [TestObject.self, TestObject2.self]
    }
    
    func testImplicitTypingOfUntypedObjectArray() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = VariantArray()
        objectsArray.append(nil)
        objectsArray.append(Variant(object0))
        objectsArray.append(Variant(object1))
        objectsArray.append(nil)
        objectsArray.append(Variant(object2))
        objectsArray.append(nil)
                
        XCTAssertEqual(testObject.call(method: "countObjects", objectsArray.toVariant()).to(), 6)
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }
    
    func testImplicitTypingOfUntypedObjectArrayFailure() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = VariantArray()
        objectsArray.append(nil)
        objectsArray.append(Variant(object0))
        objectsArray.append(Variant(object1))
        objectsArray.append(nil)
        objectsArray.append(Variant(object2))
        objectsArray.append(nil)
        objectsArray.append(Variant(RefCounted())) // this one causes the failure
                
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), 0.toVariant())
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }
    
    func testExplicitlyTypedObjectArrayGodotSideMismatch() {
        let testObject = TestObject()
        
        let object0 = TestObject()
        let object1 = TestObject2()
        let object2 = TestObject()
        
        let objectsArray = VariantArray(TestObject.self)
        objectsArray.append(nil) // 1
        objectsArray.append(Variant(object0)) // 2
        objectsArray.append(Variant(object1)) // 3
        objectsArray.append(nil) // 4
        objectsArray.append(Variant(object2)) // 5
        objectsArray.append(nil) // 6
        
        // this one won't be added, error is logged from Godot, RefCounted is not TestObject
        objectsArray.append(Variant(RefCounted()))
        
        let result = testObject.call(method: "countObjects", objectsArray.toVariant())
        XCTAssertEqual(result.to(), 6)
        
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }
    
    func testTypedObjectArray() {
        let testObject = TestObject()
        
        let object0 = TestObject2()
        let object1 = TestObject()
        let object2 = TestObject()
        
        let objectsArray = TypedArray<TestObject?>()
        objectsArray.append(nil) // 1
        objectsArray.append(object0) // 2
        objectsArray.append(object1) // 3
        objectsArray.append(nil) // 4
        objectsArray.append(object2) // 5
        objectsArray.append(nil) // 6
        
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), Variant(6))
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }
    
    func testImplicitlyTypingBuiltinsArray() {
        let testObject = TestObject()
        
        let builtinsArray = VariantArray()
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }
    
    
    func testImplicitTypingOfUntypedBuiltinArrayFailure() {
        let testObject = TestObject()
        
        let array = VariantArray()
        array.append(nil)
        array.append(Variant(1))
        array.append(Variant(2))
        array.append(nil)
        array.append(Variant(3))
        array.append(nil)
        array.append(Variant(4))
        
        // Fails, prints into console and returns nil due to typed builtin array not allowing nils
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(array)), 0.toVariant())
        testObject.free()
    }
    
    func testExplicitlyTypedBuiltinArrayGodotSideMismatch() {
        let testObject = TestObject()
        
        let builtinsArray = VariantArray(Int.self)
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        // this one won't be added, error is logged from Godot, nil Builtins are not allowed in typed Arrays
        builtinsArray.append(nil)
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }
    
    func testExplicitlyTypedBuiltinArray() {
        let testObject = TestObject()
        
        let builtinsArray = TypedArray<Int>()
        builtinsArray.append(1)
        builtinsArray.append(2)
        builtinsArray.append(3)
        
        XCTAssertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }
    
    func testCountMixed() {
        let testObject = TestObject()
        
        let builtins = VariantArray(Int.self)
        builtins.append(Variant(1)) // 1
        
        let objects = TypedArray<RefCounted?>()
        objects.append(nil) // 2
        objects.append(RefCounted()) // 3
        
        let variants = VariantArray()
        variants.append(nil) // 4
        variants.append(Variant(RefCounted())) // 5
        variants.append(Variant("Foo")) // 6
        variants.append(Variant(true)) // 7
        
        
        XCTAssertEqual(testObject.call(method: "countMixed", Variant(builtins), Variant(objects), Variant(variants), Variant("ignored")), Variant(7))
        testObject.free()
    }
}
