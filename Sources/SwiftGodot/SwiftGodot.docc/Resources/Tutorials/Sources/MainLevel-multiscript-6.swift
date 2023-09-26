//
//  MainLevel.swift
//  
//
//  Created by Marquis Kurt on 7/22/23.
//

import Foundation
import SwiftGodot

@Godot
class MainLevel: Node2D {
    var player: PlayerController?
    var spawnpoint: Node2D?
    var teleportArea: Area2D?

    override func _ready() {
        self.player = getNodeOrNull(path: "CharacterBody2D") as? PlayerController
        self.teleportArea = getNodeOrNull(path: "Telepoint") as? Area2D
        self.spawnpoint = getNodeOrNull(path: "Spawnpoint") as? Node2D
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
