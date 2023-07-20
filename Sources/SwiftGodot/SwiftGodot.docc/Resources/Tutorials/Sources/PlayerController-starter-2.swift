//
//  PlayerController.swift
//
//
//  Created by Marquis Kurt on 7/19/23.
//

import Foundation
import SwiftGodot

class PlayerController: CharacterBody2D {
    required init() {
        super.init()
    }
    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) not supported")
    }
}
