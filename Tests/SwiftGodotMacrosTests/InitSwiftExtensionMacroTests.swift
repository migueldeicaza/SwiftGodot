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
                let types: [Wrapped.Type] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (register)
                    default:
                        break
                    }
                }, deInitHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (unregister)
                    default:
                        break
                    }
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
                let types: [Wrapped.Type] = []
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (register)
                    default:
                        break
                    }
                }, deInitHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (unregister)
                    default:
                        break
                    }
                })
                return 1
            }
            """,
            macros: testMacros
        )
    }

    func testInitSwiftExtensionMacro() {
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
                let types: [Wrapped.Type] = [ChrysalisNode.self]
                initializeSwiftModule (interface, library, `extension`, initHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (register)
                    default:
                        break
                    }
                }, deInitHook: { level in
                    switch level {
                    case .scene:
                        types.forEach (unregister)
                    default:
                        break
                    }
                })
                return 1
            }
            """,
            macros: testMacros
        )
    }
}
