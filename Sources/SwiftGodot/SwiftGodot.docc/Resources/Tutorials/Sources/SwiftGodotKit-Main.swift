//
//  main.swift
//  SimpleGodotApp
//
//  Created by Miguel de Icaza on 9/6/23.
//

import Foundation
import SwiftGodotKit
import SwiftGodot

func loadScene (scene: SceneTree) {
    let rootNode = Node3D()
    let camera = Camera3D ()
    camera.current = true
    camera.position = Vector3(x: 0, y: 0, z: 2)
    
    rootNode.addChild(node: camera)
    
    func makeCuteNode (_ pos: Vector3) -> Node {
        let n = SpinningCube()
        n.position = pos
        return n
    }
    rootNode.addChild(node: makeCuteNode(Vector3(x: 1, y: 1, z: 1)))
    rootNode.addChild(node: makeCuteNode(Vector3(x: -1, y: -1, z: -1)))
    rootNode.addChild(node: makeCuteNode(Vector3(x: 0, y: 1, z: 1)))
    scene.root?.addChild(node: rootNode)
}

@Godot
class SpinningCube: Node3D {
    override func _ready () {
        let meshRender = MeshInstance3D()
        meshRender.mesh = BoxMesh()
        addChild(node: meshRender)
    }   

    override func _input (event: InputEvent) {
        guard event.isPressed () && !event.isEcho () else { return }
        print ("SpinningCube: event: isPressed ")
    }
    
    public override func _process(delta: Double) {
        rotateY(angle: delta)
    }
}

func registerTypes (level: GDExtension.InitializationLevel) {
    switch level {
    case .scene:
        register (type: SpinningCube.self)
    default:
        break
    }
}

guard let projectPath = Bundle.module.path(forResource: "Project", ofType: nil) else {
    fatalError("Could not load resource path")
}

runGodot(args: ["--path", projectPath], initHook: registerTypes, loadScene: loadScene, loadProjectSettings: { settings in })
