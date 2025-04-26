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

// This shows how to register methods and properties manually
class SwiftSprite: Sprite2D {
    var time_passed: Double
    var count: Int
    
    // This is a class initializer, must be invoked from all of your constructors to register the various
    // features of this class with the Godot engine.
    static var initClass: Void = {
        let classInfo = ClassInfo<SwiftSprite> (name: "SwiftSprite")
        
        classInfo.addPropertyGroup(name: "Miguel's Demo", prefix: "demo_")
        
        let foodArgs = [
            PropInfo(propertyType: .string,
                     propertyName: "Food",
                     className: StringName ("food"),
                     hint: .typeString,
                     hintStr: "Some kind of food",
                     usage: .default)
        ]
        classInfo.registerMethod(name: "demo_set_favorite_food", flags: .default, returnValue: nil, arguments: foodArgs, function: SwiftSprite.demoSetFavoriteFood)
        classInfo.registerMethod(name: "demo_get_favorite_food", flags: .default, returnValue: foodArgs [0], arguments: [], function: SwiftSprite.demoGetFavoriteFood)
        
        let foodProp = PropInfo (propertyType: .string,
                                 propertyName: "demo_favorite_food",
                                 className: "SwiftSprite",
                                 hint: .multilineText,
                                 hintStr: "Name of your favorite food",
                                 usage: .default)
        classInfo.registerProperty(foodProp, getter: "demo_get_favorite_food", setter: "demo_set_favorite_food")
    }()
        
    required init(_ nativeObjectHandle: NativeObjectHandle) {
        _ = SwiftSprite.initClass
        count = sequence
        sequence += 1
        time_passed = 0
        
        super.init(nativeObjectHandle)
    }
    
    deinit {
        print ("SwiftSprite: Releasing \(count)")
    }
    
    // This callback style receives the arguments from Godot as an array of Variants, and returns a Variant
    // harder than using the macros above
    var food: String = "none"
    func demoSetFavoriteFood (args: borrowing Arguments) -> Variant? {
        guard let arg = args.first else {
            print ("Method registered taking one argument got none")
            return nil
        }
        
        guard let variant = arg else {
            print ("Method registered taking an non-nil argument, got nil")
            return nil
        }
        
        food = String (variant) ?? "The variant passed was not a string"
        print ("The favorite food was set to: \(food)")
        return nil
    }
    
    func demoGetFavoriteFood (args: borrowing Arguments) -> Variant? {
        let variant = Variant(food)
        
        return variant
    }

    override func _process (delta: Double) {
        time_passed += delta
                
        guard let imageVariant = ProjectSettings.getSetting(name: "shader_globals/heightmap", defaultValue: Variant(-1)) else {
            return
        }
        
        GD.print("Found this value IMAGE: \(imageVariant.gtype) variant: \(imageVariant) desc: \(imageVariant.description)")
        
        let dict2: VariantDictionary? = VariantDictionary(imageVariant)
        GD.print("dictionary2: \(String(describing: dict2)) \(dict2?["type"]?.description ?? "no value for type") \(dict2?["value"]?.description ?? "no value for value")")
        
        // part b
        if let result = dict2?.get(key: Variant("type"), default: Variant(-1)) {
            let value = String(result)
            GD.print("2 Found this value \(value ?? "no value found")")
        }
        
        let newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}

/// Setup 
func setupScene (level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: Rigid.self)
        register(type: SwiftSprite.self)
    }
}

/// Manually defined entry point for the extension.
@_cdecl("swift_entry_point")
public func swift_entry_point(
    godotGetProcAddr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("ManualExtension: Starting up")
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(godotGetProcAddr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
