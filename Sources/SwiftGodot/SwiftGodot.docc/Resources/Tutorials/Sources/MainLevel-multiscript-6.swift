//
//  MainLevel.swift
//  
//
//  Created by Marquis Kurt on 7/22/23.
//

import SwiftGodot

@Godot
class MainLevel: Node2D {
    @Node("CharacterBody2D") var player: PlayerController?
    @Node("Spawnpoint") var spawnpoint: Node2D?
    @Node("Telepoint") var teleportArea: Area2D?

    override func _ready() {
        teleportArea?.bodyEntered.connect { [self] enteredBody in
            if enteredBody.isClass("\(PlayerController.self)") {
                teleportPlayerToTop()
            }
        }
    }

    private func teleportPlayerToTop() {
        guard let player, let spawnpoint else {
            GD.pushWarning("Player or spawnpoint is missing.")
            return
        }

        player.position = Vector2(x: player.position.x, y: spawnpoint.position.y)
    }
}
