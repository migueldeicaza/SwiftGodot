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

func someFunc() -> Node3D {
    fatalError()
}

@Godot
class MultiBindingExample: Node {
//    @Export var one: String = "one", two: Bool = false, three: Int = 50
}

enum MyEnum: Int, CaseIterable {
    case first = 10
    case late = 20
}

typealias SomeArray = [Int]

@Godot
class SwiftSprite: Sprite2D {    
    var time_passed: Double = 0
    var count: Int = 0
    
    @Export
    var someCollection: VariantCollection<Int> = [1, 2, 3, 4]
    
    @Signal var pickedUpItem: SignalWithArguments<String, Bool, Int>
    @Signal var scored: SimpleSignal
    @Signal var livesChanged: SignalWithArguments<Int>
    
    
    @Callable
    public func computeGodot (x: String, y: Int) -> Double {
        return 1.0
    }

    @Callable
    public func wink () {
        print ("Wink")
    }
    
    @Callable
    public func computerSimple (_ x: Int, _ y: Int) -> Double {
        return Double (x + y)
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
    
    var x: Rigid?
    
    override func _process (delta: Double) {
        time_passed += delta
    
        if x == nil {
            self.x = Rigid()
        }
        guard let imageVariant = ProjectSettings.getSetting(name: "shader_globals/heightmap", defaultValue: Variant(-1)) else {
            return
        }
        
        GD.print("Found this value IMAGE: \(imageVariant.gtype) variant: \(imageVariant) desc: \(imageVariant.description)")
        
        let dict2: GDictionary? = GDictionary(imageVariant)
        GD.print("dictionary2: \(String(describing: dict2)) \(dict2?["type"]?.description ?? "no type") \(dict2?["value"]?.description ?? "no value")")
        
        // part b
        if let result = dict2?.get(key: Variant("type"), default: Variant(-1)) {
            let value = String(result) ?? "No Result"
            GD.print("2 Found this value \(value)")
        }
        
        let lerp = Double(0.1).lerp(to: 10, weight: 1)
        print ("Lerp result from 0.1 to 10 weight:1 => \(lerp)")
        let newPos = Vector2(x: Float (10 + (10 * sin(time_passed * 2.0))),
                             y: Float (10.0 + (10.0 * cos(time_passed * 1.5))))
        
        self.position = newPos
    }
}
