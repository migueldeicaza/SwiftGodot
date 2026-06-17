//
//  MacroCallableIntegrationTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 12/10/2024.
//



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

@Godot
fileprivate class DefaultArgObject: Object {
    enum Mode: Int, CaseIterable {
        case slow = 0
        case fast = 7
    }

    @Callable
    func greet(_ name: String, greeting: String = "Hello", times: Int = 2) -> String {
        Array(repeating: "\(greeting), \(name)", count: times).joined(separator: " ")
    }

    @Callable
    func attach(to node: Object? = nil) -> Bool {
        node != nil
    }

    @Callable
    func describe(prefix: String = "mode", mode: Mode = .fast) -> String {
        "\(prefix):\(mode.rawValue)"
    }
}

@SwiftGodotTestSuite
final class MacroCallableIntegrationTests {
    public static var registeredTypes: [Object.Type] {
        return [TestObject.self, TestObject2.self, DefaultArgObject.self]
    }

    public func testDefaultArgumentsOmitted() {
        let object = DefaultArgObject()

        // All defaults applied: greeting = "Hello", times = 2
        assertEqual(object.call(method: "greet", Variant("World")), Variant("Hello, World Hello, World"))
        // Trailing default applied: times = 2
        assertEqual(object.call(method: "greet", Variant("World"), Variant("Hi")), Variant("Hi, World Hi, World"))
        // No defaults applied
        assertEqual(object.call(method: "greet", Variant("World"), Variant("Hi"), Variant(1)), Variant("Hi, World"))

        object.free()
    }

    public func testDefaultArgumentNil() {
        let object = DefaultArgObject()

        // Omitted optional object argument defaults to nil
        assertEqual(object.call(method: "attach"), Variant(false))
        assertEqual(object.call(method: "attach", Variant(object)), Variant(true))

        object.free()
    }

    public func testEnumDefaultArgument() {
        let object = DefaultArgObject()

        // Both defaults applied: prefix = "mode", mode = .fast (7)
        assertEqual(object.call(method: "describe"), Variant("mode:7"))
        // Trailing enum default applied: mode = .fast (7)
        assertEqual(object.call(method: "describe", Variant("speed")), Variant("speed:7"))
        // Enum supplied explicitly (as its raw Int value)
        assertEqual(object.call(method: "describe", Variant("speed"), Variant(DefaultArgObject.Mode.slow.rawValue)), Variant("speed:0"))

        object.free()
    }

    public func testDefaultEnumArgumentTranslatedViaClassDB() {
        // Inspect the registered method metadata directly through Godot's ClassDB to prove the
        // `.fast` enum default was evaluated to its raw value (7) — not its declaration order (1),
        // not a zero literal — and that the argument slot is registered as the Mode enum, so the
        // default genuinely lives in an enum-typed parameter rather than a bare integer.
        let methods = ClassDB.classGetMethodList(class: "DefaultArgObject", noInheritance: true)

        guard let describe = methods.first(where: { String($0["name"]) == "describe" }) else {
            fail("Expected to find a 'describe' method on DefaultArgObject")
            return
        }

        guard let defaultArgs = describe["default_args"]?.to(VariantArray.self) else {
            fail("'describe' method is missing default_args")
            return
        }

        // Trailing defaults only: prefix = "mode", mode = .fast
        assertEqual(defaultArgs.count, 2)
        assertEqual(defaultArgs[0], Variant("mode"))
        // .fast.rawValue == 7, while its ordinal position is 1. A registered value of 7 proves the
        // enum case was resolved to its raw value, not stored as a literal/ordinal.
        assertEqual(defaultArgs[1], Variant(DefaultArgObject.Mode.fast.rawValue))
        assertEqual(defaultArgs[1], Variant(7))

        // The `mode` argument must be registered as the Mode enum (class_name + classIsEnum usage).
        guard let args = describe["args"]?.to(VariantArray.self),
              let modeArg = args[1]?.to(VariantDictionary.self) else {
            fail("'describe' method is missing argument metadata")
            return
        }

        if let classV = modeArg["class_name"] {
            assertEqual(String(classV), "DefaultArgObject.Mode")
        } else {
            fail("'mode' argument is missing a class_name")
        }

        if let flagsV = modeArg["usage"], let iflags = Int(flagsV) {
            assertTrue(PropertyUsageFlags(rawValue: iflags).contains(.classIsEnum),
                       "'mode' argument should have the classIsEnum usage flag")
        } else {
            fail("'mode' argument is missing usage flags")
        }
    }

    public func testImplicitTypingOfUntypedObjectArray() {
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
                
        assertEqual(testObject.call(method: "countObjects", objectsArray.toVariant()).to(), 6)
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }

    public func testImplicitTypingOfUntypedObjectArrayFailure() {
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
                
        assertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), 0.toVariant())
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }

    public func testExplicitlyTypedObjectArrayGodotSideMismatch() {
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
        assertEqual(result.to(), 6)
        
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }

    public func testTypedObjectArray() {
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
        
        assertEqual(testObject.call(method: "countObjects", Variant(objectsArray)), Variant(6))
        testObject.free()
        object0.free()
        object1.free()
        object2.free()
    }

    public func testImplicitlyTypingBuiltinsArray() {
        let testObject = TestObject()
        
        let builtinsArray = VariantArray()
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        
        assertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }

    public func testImplicitTypingOfUntypedBuiltinArrayFailure() {
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
        assertEqual(testObject.call(method: "countObjects", Variant(array)), 0.toVariant())
        testObject.free()
    }

    public func testExplicitlyTypedBuiltinArrayGodotSideMismatch() {
        let testObject = TestObject()
        
        let builtinsArray = VariantArray(Int.self)
        builtinsArray.append(Variant(1))
        builtinsArray.append(Variant(2))
        builtinsArray.append(Variant(3))
        // this one won't be added, error is logged from Godot, nil Builtins are not allowed in typed Arrays
        builtinsArray.append(nil)
        
        assertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }

    public func testExplicitlyTypedBuiltinArray() {
        let testObject = TestObject()
        
        let builtinsArray = TypedArray<Int>()
        builtinsArray.append(1)
        builtinsArray.append(2)
        builtinsArray.append(3)
        
        assertEqual(testObject.call(method: "countBuiltins", Variant(builtinsArray)), Variant(3))
        testObject.free()
    }

    public func testCountMixed() {
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
        
        
        assertEqual(testObject.call(method: "countMixed", Variant(builtins), Variant(objects), Variant(variants), Variant("ignored")), Variant(7))
        testObject.free()
    }
}
