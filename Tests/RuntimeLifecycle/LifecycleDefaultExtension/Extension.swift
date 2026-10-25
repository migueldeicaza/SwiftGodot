import SwiftGodot

@Godot
class LifecycleDefaultResource: Resource {}

@Godot
class LifecycleDefaultNode: Node {
    @Export var data: LifecycleDefaultResource = LifecycleDefaultResource()
}

func registerLifecycleDefaults(level: ExtensionInitializationLevel) {
    if level == .scene {
        register(type: LifecycleDefaultResource.self)
        register(type: LifecycleDefaultNode.self)
    }
}

@_cdecl("lifecycle_defaults_entry_point")
public func lifecycle_defaults_entry_point(
    godotGetProcAddr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?
) -> UInt8 {
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        return 0
    }
    // Keep classes registered until Godot clears its property default cache.
    initializeSwiftModule(
        godotGetProcAddr, libraryPtr, extensionPtr,
        initHook: registerLifecycleDefaults,
        deInitHook: { _ in }
    )
    return 1
}
