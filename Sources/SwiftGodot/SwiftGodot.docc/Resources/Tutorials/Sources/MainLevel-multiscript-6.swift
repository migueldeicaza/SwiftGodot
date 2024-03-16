//
//  MainLevel.swift
//  
//
//  Created by Marquis Kurt on 7/22/23.
//

import SwiftGodot

@Godot
class MainLevel: Node2D {
    @SceneTree(path: "CharacterBody2D") var player: PlayerController?
    @SceneTree(path: "Spawnpoint") var spawnpoint: Node2D?
    @SceneTree(path: "Telepoint") var teleportArea: Area2D?

    override func _ready() {
        teleportArea?.bodyEntered.connect { [self] enteredBody in
            if enteredBody.isClass("\(PlayerController.self)") {
                teleportPlayerToTop()
            }
        }

        super._ready()
    }

    private func teleportPlayerToTop() {
        guard let player, let spawnpoint else {
            GD.pushWarning("Player or spawnpoint is missing.")
            return
        }

        player.position = Vector2(x: player.position.x, y: spawnpoint.position.y)
    }
}
