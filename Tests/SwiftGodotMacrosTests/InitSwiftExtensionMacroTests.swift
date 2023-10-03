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

    func testInitSwiftExtensionMacro() {
        assertMacroExpansion(
            """
            #initSwiftExtension(cdecl: "libchrysalis_entry_point", types: [ChrysalisNode.self])
            """,
            expandedSource: """
            @_cdecl("libchrysalis_entry_point") public func enterExtension(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
                guard let library, let interface, let `extension` else {
                    print("Error: Not all parameters were initialized.")
                    return 0
                }
                let deinitHook: (GDExtension.InitializationLevel) -> Void = { _ in
                }
                initializeSwiftModule(interface, library, `extension`, initHook: setupExtension, deInitHook: deinitHook)
                return 1
            }
            func setupExtension(level: GDExtension.InitializationLevel) {
                let types = [ChrysalisNode.self]
                switch level {
                case .scene:
                    types.forEach(register)
                default:
                    break
                }
            }
            """,
            macros: testMacros
        )
    }
}
