//
//  Demo.swift
//
//  Created by Miguel de Icaza on 4/4/23.
//

import Foundation
import SwiftGodot

var sequence = 0

class SwiftSprite: Sprite2D {
    var time_passed: Double
    var count: Int
    
    static var initClass: Void = {
        let classInfo = ClassInfo<SwiftSprite> (name: "SwiftSprite")
        
        classInfo.addPropertyGroup(name: "Miguel's Demo", prefix: "demo_")
        
        let foodArgs = [
            PropInfo(propertyType: .string,
                     propertyName: "Food",
                     className: StringName ("food"),
                     hint: .typeString,
                     hintStr: "Some kind of food",
                     usage: .propertyUsageDefault)
        ]
        classInfo.registerMethod(name: "demo_set_favorite_food", flags: .default, returnValue: nil, arguments: foodArgs, function: SwiftSprite.demoSetFavoriteFood)
        classInfo.registerMethod(name: "demo_get_favorite_food", flags: .default, returnValue: foodArgs [0], arguments: [], function: SwiftSprite.demoGetFavoriteFood)
        
        let foodProp = PropInfo (propertyType: .string,
                                 propertyName: "demo_favorite_food",
                                 className: "SwiftSprite",
                                 hint: .multilineText,
                                 hintStr: "Name of your favorite food",
                                 usage: .propertyUsageDefault)
        classInfo.registerProperty(foodProp, getter: "demo_get_favorite_food", setter: "demo_set_favorite_food")
    }()
    
    required init (nativeHandle: UnsafeRawPointer) {
        SwiftSprite.initClass
        time_passed = 0
        count = sequence
        super.init (nativeHandle: nativeHandle)
    }
    
    required init () {
        SwiftSprite.initClass
        count = sequence
        sequence += 1
        time_passed = 0
        super.init ()
    }
    
    deinit {
        print ("SwiftSprite: Releasing \(count)")
    }
    
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

        let imageVariant = ProjectSettings.shared.getSetting(name: "shader_globals/heightmap", defaultValue: Variant(-1))
               GD.print("Found this value IMAGE: \(imageVariant.gtype) variant: \(imageVariant) desc: \(imageVariant.description)")
               
               let dict2: Dictionary? = SwiftGodot.Dictionary(imageVariant)
               GD.print("dictionary2: \(dict2) \(dict2?["type"]) \(dict2?["value"])")
               
       // part b
               if let result = dict2?.get(key: Variant("type"), default: Variant(-1)) {
                   let value = String(result)
                   GD.print("2 Found this value \(value)")
               }
        
        SwiftSprite.lerp (from: 0.1, to: 10, weight: 1)
        var newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}

func setupScene (level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: SwiftSprite.self)
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
