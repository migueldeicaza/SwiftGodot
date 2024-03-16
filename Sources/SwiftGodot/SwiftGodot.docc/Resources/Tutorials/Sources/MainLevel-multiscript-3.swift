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

}
