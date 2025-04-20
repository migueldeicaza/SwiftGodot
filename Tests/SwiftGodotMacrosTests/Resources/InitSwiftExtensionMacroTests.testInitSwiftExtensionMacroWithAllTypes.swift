@_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let library, let interface, let `extension` else {
        print ("Error: Not all parameters were initialized.")
        return 0
    }
    var types: [GDExtension.InitializationLevel: [Object.Type]] = [:]
    types[.core] = [EggNode.self]
    types[.editor] = [CaterpillarNode.self]
    types[.scene] = [ChrysalisNode.self]
    types[.servers] = [ButterflyNode.self]
    initializeSwiftModule (interface, library, `extension`, initHook: { level in
        types[level]?.forEach (register)
    }, deInitHook: { level in
        types[level]?.forEach (unregister)
    })
    return 1
}