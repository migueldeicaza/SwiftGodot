//
//  Various.swift: Support functions
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

public extension SceneTree {
    /// Public because we want to allow the embed API to call this, but dont want to make it
    /// obvious in the constructors
    static func createFrom(nativeHandle: UnsafeMutableRawPointer) -> SceneTree {
        return SceneTree(NativeObjectHandle(pNativeObject: nativeHandle, constructedFromSwift: false))
    }
}

extension Object: CustomStringConvertible {
    public var description: String {
        return toString().description
    }
}

public extension ProjectSettings {
    /// Public because we want to allow the embed API to call this, but dont want to make it
    /// obvious in the constructors
    static func createFrom(nativeHandle: UnsafeMutableRawPointer) -> ProjectSettings {
        return ProjectSettings(NativeObjectHandle(pNativeObject: nativeHandle, constructedFromSwift: false))
    }
}

public extension TextServer {
    /// **Warning:** This is a required internal node, removing and freeing it may cause a crash. If you wish to hide it or any of its children, use their ``CanvasItem/visible`` property.  ``SwiftGodot``
    func demo () {
        
    }
}

 
