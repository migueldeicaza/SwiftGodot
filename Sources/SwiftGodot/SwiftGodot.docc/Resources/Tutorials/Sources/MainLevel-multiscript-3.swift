//
//  MainLevel.swift
//  
//
//  Created by Marquis Kurt on 7/22/23.
//

import Foundation
import SwiftGodot

class MainLevel: Node2D {
    var player: PlayerController?
    var spawnpoint: Node2D?
    var teleportArea: Area2D?

    required init() {
        super.init()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) not implemented")
    }
}
