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

}
