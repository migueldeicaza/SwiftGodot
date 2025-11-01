@_cdecl("libchrysalis_entry_point") public func enterExtension(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let library, let interface, let `extension` else {
        print ("Error: Not all parameters were initialized.")
        return 0
    }

    var types: [GDExtension.InitializationLevel: [Object.Type]] = [:]
    types[.core] = [ChrysalisNode.self].topologicallySorted()
    types[.editor] = [].topologicallySorted()
    types[.scene] = [].topologicallySorted()
    types[.servers] = [].topologicallySorted()
    initializeSwiftModule (interface, library, `extension`, initHook: { level in
        types[level]?.forEach(register)
    }, deInitHook: { level in
        types[level]?.reversed().forEach(unregister)
    }, minimumInitializationLevel: minimumInitializationLevel(for: types))
    return 1
}