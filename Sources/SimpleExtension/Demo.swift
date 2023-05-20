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
    
    override func _process (delta: Double) {
        time_passed += delta
        
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
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftSprite: Starting up")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
