@_cdecl("libchrysalis_entry_point") public func enterExtension(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let library, let interface, let `extension` else {
        print ("Error: Not all parameters were initialized.")
        return 0
    }

    let types: [GDExtension.InitializationLevel: [Object.Type]]
    do {
        types = try [].prepareForRegistration()
    } catch {
        GD.printErr("Error during GDExtension initialization: \(error)")
        return 0
    }
    initializeSwiftModule (interface, library, `extension`, initHook: { level in
        types[level]?.forEach(register)
    }, deInitHook: { level in
        types[level]?.reversed().forEach(unregister)
    }, minimumInitializationLevel: minimumInitializationLevel(for: types))
    return 1
}