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
}

@Godot
fileprivate class TestObject2: TestObject {
    
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
        
        // Fails, prints into consoke and returns nil due to RefCounted not being TestObject
        XCTAssertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), nil)
    }
    
    func testExplicitTypingOfUntypedObjectArrayFailure() {
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
        objectsArray.append(Variant(RefCounted())) // this one won't be added with a error log from Godot
        
        // Fails, prints into consoke and returns nil due to RefCounted not being TestObject
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
}
