//
//  MacroGodotTests.swift
//  
//
//  Created by Padraig O Cinneide on 2023-09-28.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftGodotMacroLibrary

// Note when editing: use spaces for indentation, check that Xcode has following settings, if some tests fail without an obvious actual and expected output difference
// Text Editing / Indentation
// Prefer Indent Using = Spaces
// Tab Key = Indents in leading whitespace

final class MacroGodotTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Callable": GodotCallable.self,
            "Export": GodotExport.self,
            "signal": SignalMacro.self
        ]
    }
    
    func testGodotMacro() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
            }
            """
        )
    }

    func testGodotMacroWithFinalClass() {
        assertExpansion(
            of: """
            @Godot final class Hi: Node {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """
        )
    }

    func testGodotVirtualMethodsMacro() {
        assertExpansion(
            of: """
            @Godot(.tool) class Hi: Control {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """
        )
    }
    
    func testGodotMacroWithNonCallableFunc() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                func hi() {
                }
            }
            """
        )
    }
    func testGodotMacroStaticSignal() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                #signal("picked_up_item", arguments: ["kind": String.self])
                #signal("scored")
                #signal("different_init", arguments: [:])
                #signal("different_init2", arguments: .init())
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncWithObjectParams() {
        assertExpansion(
            of: """
            @Godot class Castro: Node {
                @Callable func deleteEpisode() {}
                @Callable func subscribe(podcast: Podcast) {}
                @Callable func perhapsSubscribe(podcast: Podcast?) {}
                @Callable func removeSilences(from: Variant) {}
                @Callable func getLatestEpisode(podcast: Podcast) -> Episode {}
                @Callable func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}
            }
            """
        )
    }
    
    func testWarningAvoidance() {
        assertExpansion(
            of: """
            @Godot
            final class MyData: Resource {}
            
            @Godot
            final class MyClass: Node {
                @Export var data: MyData = .init()
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithVariantCollectionReturnType() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func getIntegerCollection() -> VariantCollection<Int> {
                    let result: VariantCollection<Int> = [0, 1, 1, 2, 3, 5, 8]
                    return result
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithVariantCollectionParam() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func square(_ integers: VariantCollection<Int>) -> VariantCollection<Int> {
                    integers.map { $0 * $0 }.reduce(into: VariantCollection<Int>()) { $0.append(value: $1) }
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithObjectCollectionReturnType() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func getNodeCollection() -> ObjectCollection<Node> {
                    let result: ObjectCollection<Node> = [Node(), Node()]
                    return result
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithObjectCollectionParam() {        
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func printNames(of nodes: ObjectCollection<Node>) {
                    nodes.forEach { print($0.name) }
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithArrayParam() {
        assertExpansion(
            of: """
            @Godot
            class MultiplierNode: Node {
                @Callable
                func multiply(_ integers: [Int]) -> Int {
                    integers.reduce(into: 1) { $0 *= $1 }
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncHavingVariantsInSignature() {
        assertExpansion(
            of: """
            @Godot
            private class TestNode: Node {
                @Callable
                func foo(variant: Variant?) -> Variant? {
                    return variant
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithArrayReturnTypes() {
        assertExpansion(
            of: """
            @Godot
            class CallableCollectionsNode: Node {
                @Callable
                func get_ages() -> [Int] {
                    [1, 2, 3, 4]
                }
            
                @Callable
                func get_markers() -> [Marker3D] {
                    [.init(), .init(), .init()]
                }
            }
            """
        )
    }

    func testGodotMacroWithCallableFuncsWithGenericArrayParam() {
        assertExpansion(
            of: """
            @Godot
            class MultiplierNode: Node {
                @Callable
                func multiply(_ integers: Array<Int>) -> Int {
                    integers.reduce(into: 1) { $0 *= $1 }
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithGenericArrayReturnTypes() {
        assertExpansion(
            of: """
            @Godot
            class CallableCollectionsNode: Node {
                @Callable
                func get_ages() -> Array<Int> {
                    [1, 2, 3, 4]
                }
            
                @Callable
                func get_markers() -> Array<Marker3D> {
                    [.init(), .init(), .init()]
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncWithValueParams() {
        assertExpansion(
            of: """
            @Godot class MathHelper: Node {
                @Callable func multiply(_ a: Int, by b: Int) -> Int { a * b}
                @Callable func divide(_ a: Float, by b: Float) -> Float { a / b }
                @Callable func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }
            }
            """
        )
    }
    
    func testExportGodotUsage() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Export(usage: [.editor, .array]) var goodName: String = "Supertop"
            }
            """
        )
    }
    
    func testExportedInt64() {
        assertExpansion(
            of: """
            @Godot
            class Thing: SwiftGodot.Object {
                @Export
                var value: Int64 = 0
            
                @Callable func get_some() -> Int64 { 10 }
            }
            """
        )
    }

    func testExportGodotMacro() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Export var goodName: String = "Supertop"
            }
            """
        )
    }
}
