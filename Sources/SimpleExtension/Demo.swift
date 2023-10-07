//
//  Demo.swift
//
//  Created by Miguel de Icaza on 4/4/23.
//

import Foundation
import SwiftGodot

var sequence = 0

@Godot
class Rigid: RigidBody2D {
    override func _integrateForces(state: PhysicsDirectBodyState2D?) {
        guard let xform = state?.transform else {
            return
        }
        print (xform)
    }
}

@Godot
class SwiftSprite: Sprite2D {
    var time_passed: Double = 0
    var count: Int = 0

    @Callable
    public func computeGodot (x: String, y: Int) -> Double {
        return 1.0
    }

    @Callable
    public func wink () {
        print ("Wink")
    }
    
    @Callable
    public func computerSimple (_ x: Int, _ y: Int) -> Float {
        return Float (x + y)
    }
    
    @Callable 
    func returnNullable () -> String? {
        let x: Variant = Variant (1)
        if let y: Resource = x.asObject () {
            print ("Y is = \(y)")
        }
        return nil
    }
    
    @Export var resource: Resource?
    @Export(.dir) var directory: String?
    @Export(.file, "*txt") var file: String?
    @Export var demo: String = "demo"
    @Export var food: String = "none"

    static func lerp(from: Float, to: Float, weight: Float) -> Float {
        return Float(GD.lerp(from: Variant(from), to: Variant(to), weight: Variant(weight))) ?? 0
    }
    
    var x: Rigid?
    
    override func _process (delta: Double) {
        time_passed += delta
    
        if x == nil {
            self.x = Rigid()
        }
        let imageVariant = ProjectSettings.getSetting(name: "shader_globals/heightmap", defaultValue: Variant(-1))
        GD.print("Found this value IMAGE: \(imageVariant.gtype) variant: \(imageVariant) desc: \(imageVariant.description)")
        
        let dict2: GDictionary? = GDictionary(imageVariant)
        GD.print("dictionary2: \(String(describing: dict2)) \(dict2?["type"] ?? "no type") \(dict2?["value"] ?? "no value")")
        
        // part b
        if let result = dict2?.get(key: Variant("type"), default: Variant(-1)) {
            let value = String(result) ?? "No Result"
            GD.print("2 Found this value \(value)")
        }
        
        let lerp = SwiftSprite.lerp (from: 0.1, to: 10, weight: 1)
        print ("Lerp result from 0.1 to 10 weight:1 => \(lerp)")
        let newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}

// This shows how to register methods and properties manually
class SwiftSprite2: Sprite2D {
    var time_passed: Double
    var count: Int
    
    // This is a class initializer, must be invoked from all of your constructors to register the various
    // features of this class with the Godot engine.
    static var initClass: Void = {
        let classInfo = ClassInfo<SwiftSprite2> (name: "SwiftSprite2")
        
        classInfo.addPropertyGroup(name: "Miguel's Demo", prefix: "demo_")
        
        let foodArgs = [
            PropInfo(propertyType: .string,
                     propertyName: "Food",
                     className: StringName ("food"),
                     hint: .typeString,
                     hintStr: "Some kind of food",
                     usage: .default)
        ]
        classInfo.registerMethod(name: "demo_set_favorite_food", flags: .default, returnValue: nil, arguments: foodArgs, function: SwiftSprite2.demoSetFavoriteFood)
        classInfo.registerMethod(name: "demo_get_favorite_food", flags: .default, returnValue: foodArgs [0], arguments: [], function: SwiftSprite2.demoGetFavoriteFood)
        
        let foodProp = PropInfo (propertyType: .string,
                                 propertyName: "demo_favorite_food",
                                 className: "SwiftSprite",
                                 hint: .multilineText,
                                 hintStr: "Name of your favorite food",
                                 usage: .default)
        classInfo.registerProperty(foodProp, getter: "demo_get_favorite_food", setter: "demo_set_favorite_food")
    }()
    
    required init (nativeHandle: UnsafeRawPointer) {
        _ = SwiftSprite2.initClass
        time_passed = 0
        count = sequence
        super.init (nativeHandle: nativeHandle)
    }
    
    required init () {
        _ = SwiftSprite2.initClass
        count = sequence
        sequence += 1
        time_passed = 0
        super.init ()
    }
    
    deinit {
        print ("SwiftSprite: Releasing \(count)")
    }
    
    // This callback style receives the arguments from Godot as an array of Variants, and returns a Variant
    // harder than using the macros above
    var food: String = "none"
    func demoSetFavoriteFood (args: [Variant]) -> Variant? {
        guard let arg = args.first else {
            print ("Method registered taking one argument got none")
            return nil
        }
        food = String (arg) ?? "The variant passed was not a string"
        print ("The favorite food was set to: \(food)")
        return nil
    }
    
    func demoGetFavoriteFood (args: [Variant]) -> Variant? {
        return Variant(stringLiteral: food)
    }
    
    static func lerp(from: Float, to: Float, weight: Float) -> Float {
        return Float(GD.lerp(from: Variant(from), to: Variant(to), weight: Variant(weight))) ?? 0
    }


    override func _process (delta: Double) {
        time_passed += delta
        
        let imageVariant = ProjectSettings.getSetting(name: "shader_globals/heightmap", defaultValue: Variant(-1))
        GD.print("Found this value IMAGE: \(imageVariant.gtype) variant: \(imageVariant) desc: \(imageVariant.description)")
        
        let dict2: GDictionary? = GDictionary(imageVariant)
        GD.print("dictionary2: \(String(describing: dict2)) \(dict2?["type"] ?? "no value for type") \(dict2?["value"] ?? "no value for value")")
        
        // part b
        if let result = dict2?.get(key: Variant("type"), default: Variant(-1)) {
            let value = String(result)
            GD.print("2 Found this value \(value ?? "no value found")")
        }
        
        _ = SwiftSprite.lerp (from: 0.1, to: 10, weight: 1)
        let newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}

func setupScene (level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: SwiftSprite.self)
        register(type: SwiftSprite2.self)
        register(type: Rigid.self)
    }
}

// Set the swift.gdextension's entry_symbol to "swift_entry_point
@_cdecl ("swift_entry_point")
public func swift_entry_point(
    godotGetProcAddr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftSprite: Starting up")
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(godotGetProcAddr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
