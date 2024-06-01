//
//  SwiftGodotInitSwiftExtensionMacroTests.swift
//  SwiftGodot
//
//  Created by Marquis Kurt on 6/9/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodot
import SwiftGodotMacroLibrary

final class InitSwiftExtensionMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "initSwiftExtension": InitSwiftExtensionMacro.self
    ]

    func testInitSwiftExtensionMacroWithUnspecifiedTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point")
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithEmptyTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithSceneTypesOnly() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [ChrysalisNode.self])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithEditorTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", editorTypes: [CaterpillarNode.self])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithCoreTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithServerTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", serverTypes: [ButterflyNode.self])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacroWithAllTypes() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self], editorTypes: [CaterpillarNode.self], sceneTypes: [ChrysalisNode.self], serverTypes: [ButterflyNode.self])
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }
}
