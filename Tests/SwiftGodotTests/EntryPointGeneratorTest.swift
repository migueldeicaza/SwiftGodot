//
//  EntryPointGeneratorTest.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 17/10/2024.
//

import XCTest
import EntryPointGenerator
import SwiftSyntax
import SwiftParser

class EntryPointGeneratorTest: XCTestCase {
    func testVisitor() {
        let syntax = Parser.parse(source: """
        @Godot
        class ExampleNode: Node, @unchecked Sendable {
            @Export
            var someProperty: Int = 0

            @Callable
            func someMethod() {
                print("Hello from Swift!")
                
                
            }
        }
        
        @Godot(.tool)
        class AnotherNode: Node, @unchecked Sendable {
            @Export
            var someProperty: Int = 0

            @Callable
            func someMethod() {
                print("Hello from Swift!")
                
                
            }
        }
        
        class Foo {
        }
        """)
        
        
        
        let visitor = GodotMacroSearchingVisitor(viewMode: .all)
        visitor.walk(syntax)
        XCTAssertEqual(["ExampleNode", "AnotherNode"], visitor.classes)
        
    }
}
