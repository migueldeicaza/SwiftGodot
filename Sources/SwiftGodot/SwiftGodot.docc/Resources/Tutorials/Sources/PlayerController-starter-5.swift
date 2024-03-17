//
//  PlayerController.swift
//
//
//  Created by Marquis Kurt on 7/19/23.
//

import SwiftGodot

@Godot
class PlayerController: CharacterBody2D {
    var acceleration = 100
    var friction = 100
    var speed = 200

    var movementVector: Vector2 {
        var movement = Vector2.zero
        movement.x = Float(
            Input.getActionStrength(action: "move_right") - Input.getActionStrength(action: "move_left"))
        return movement.normalized()
    }

    override func _physicsProcess(delta: Double) {
        if Engine.isEditorHint() { return }
    }
}
