//
//  Various.swift: Support functions
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation

public extension SceneTree {
    /// Public because we want to allow the embed API to call this, but dont want to make it
    /// obvious in the constructors
    public static func createFrom (nativeHandle: UnsafeMutableRawPointer) -> SceneTree {
        return SceneTree (nativeHandle: nativeHandle)
    }
}

public extension ProjectSettings {
    /// Public because we want to allow the embed API to call this, but dont want to make it
    /// obvious in the constructors
    public static func createFrom (nativeHandle: UnsafeMutableRawPointer) -> ProjectSettings {
        return ProjectSettings (nativeHandle: nativeHandle)
    }
}

public extension TextServer {
    /// **Warning:** This is a required internal node, removing and freeing it may cause a crash. If you wish to hide it or any of its children, use their ``CanvasItem.visible`` property.  ``SwiftGodot``
    func demo () {
        
    }
}
