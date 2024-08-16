import MacroTesting
import XCTest

final class InitSwiftExtensionMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testInitSwiftExtensionMacroWithUnspecifiedTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point")
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = []
                types[.editor] = []
                types[.scene] = []
                types[.servers] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithEmptyTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = []
                types[.editor] = []
                types[.scene] = []
                types[.servers] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithSceneTypesOnly() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [ChrysalisNode.self])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = []
                types[.editor] = []
                types[.scene] = [ChrysalisNode.self]
                types[.servers] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithEditorTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", editorTypes: [CaterpillarNode.self])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = []
                types[.editor] = [CaterpillarNode.self]
                types[.scene] = []
                types[.servers] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithCoreTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = [EggNode.self]
                types[.editor] = []
                types[.scene] = []
                types[.servers] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithServerTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", serverTypes: [ButterflyNode.self])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
                types[.core] = []
                types[.editor] = []
                types[.scene] = []
                types[.servers] = [ButterflyNode.self]
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    types[level]?.forEach (register)
                }, deInitHook: { level in
                    types[level]?.forEach (unregister)
                })
                return 1
            }
            """
        }
    }

    func testInitSwiftExtensionMacroWithAllTypes() {
        assertMacro {
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self], editorTypes: [CaterpillarNode.self], sceneTypes: [ChrysalisNode.self], serverTypes: [ButterflyNode.self])
            """
        } expansion: {
            """
            @_cdecl("libchrysalis_entry_point") public func enterExtension (interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print ("Error: Not all parameters were initialized.")
                    return 0
                }
                var types: [GDExtension.InitializationLevel: [Wrapped.Type]] = [:]
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
            """
        }
    }

}
