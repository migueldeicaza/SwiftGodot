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
            "Rpc": GodotRpc.self,
            "signal": SignalMacro.self,
            "Signal": SignalAttachmentMacro.self
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
    
    func testGodotMacroWithCallableFuncsWithTypedArrayReturnType() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func getIntegerCollection() -> TypedArray<Int> {
                    let result: TypedArray<Int> = [0, 1, 1, 2, 3, 5, 8]
                    return result
                }
            }
            """
        )
    }
    
    func testGodotMacroWithCallableFuncsWithTypedArrayParam() {
        assertExpansion(
            of: """
            @Godot
            class SomeNode: Node {
                @Callable
                func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
                    integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
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
    
    func testNewSignalMacro() {
        assertExpansion(
            of: """
            @Godot
            class Demo: Node3D {
                @Signal var burp: SimpleSignal
            
                @Signal var livesChanged: SignalWithArguments<Int>
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
    
    // Victory, no longer needed!   We now support statics!
//    func testStaticFunction() {
//        assertExpansion(
//            of: """
//            @Godot class Hi: Node {
//                @Callable static func get_some() -> Int64 { 10 }
//            }
//            """,
//            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
//        )
//    }

    // Victory, no longer needed!   We now support statics!
//    func testClassFunction() {
//        assertExpansion(
//            of: """
//            @Godot class Hi: Node {
//                @Callable class func get_some() -> Int64 { 10 }
//            }
//            """,
//            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
//        )
//    }
//    
    func testStaticExport() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Export
                static var int = 10
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testClassExport() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Export
                class var int = 10
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testClassSignal() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Signal
                class var int: SimpleSignal
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testStaticSignal() {
        assertExpansion(
            of: """
            @Godot class Hi: Node {
                @Signal
                static var int: SimpleSignal
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testDebugThing() {
        assertExpansion(
            of: """
            @Godot
            class DebugThing: SwiftGodot.Object {
                @Signal var livesChanged: SignalWithArguments<Swift.Int>
            
                @Callable
                func do_thing(value: SwiftGodot.Variant?) -> SwiftGodot.Variant? {
                    return nil
                }
            }
            """
        )
    }
    
    func testCallableReturningOptionalObject() {
        assertExpansion(
            of: """
            @Godot class MyThing: SwiftGodot.RefCounted {

            }

            @Godot class OtherThing: SwiftGodot.Node {
                @Callable func get_thing() -> MyThing? {
                    return nil
                }
            }
            """
        )
    }
    
    func testCallableTakingOptionalBuiltin() {
        assertExpansion(
            of: """
            @Godot class MyThing: SwiftGodot.RefCounted {

            }

            @Godot class OtherThing: SwiftGodot.Node {
                @Callable func do_string(value: String?) { }
            
                @Callable func do_int(value: Int?) {  }
            
                @Callable func get_thing() -> MyThing? {
                    return nil
                }
            }
            """
        )
    }
    
    func testFuncCollision() {
        assertExpansion(
            of: """
            @Godot class OtherThing: SwiftGodot.Node {            
                @Callable func foo(value: Int?) { }
            
                @Callable func foo() -> MyThing? {
                    return nil
                }
            }
            """,
            diagnostics: [
                .init(message: "Same name `foo` for two different declarations. GDScript doesn't support it.", line: 1, column: 1)
            ]
        )
    }
    
    func testFuncAndGetterCollision() {
        assertExpansion(
            of: """
            @Godot class OtherThing: SwiftGodot.Node {            
                @Export
                var foo: Int = 0
            
                @Callable func get_foo() -> MyThing? {
                    return nil
                }
            }
            """,
            diagnostics: [
                .init(message: "Same name `get_foo` for two different declarations. GDScript doesn't support it.", line: 1, column: 1)
            ]
        )
    }
    
    func testMultipleSignalBindings() {
        assertExpansion(
            of: """
            @Godot class OtherThing: SwiftGodot.Node {            
                @Signal var signal0: SimpleSignal, signal1: SimpleSignal
            }
            """,
            diagnostics: [
                .init(message: "accessor macro can only be applied to a single variable", line: 2, column: 5)
            ]
        )
    }
    
    func testCallableAutoSnakeCase() {
        assertExpansion(
            of: """
            @Godot class TestClass: Node {
                @Callable(autoSnakeCase: true)
                func noNeedToSnakeCaseFunctionsNow() {}
            
                @Callable(autoSnakeCase: false)
                func or_is_there() {}
            
                @Callable(autoSnakeCase: false)
                func thatIsHideous() {}

                @Callable
                func defaultIsLegacyCompatible() {}
            }
            """
        )
    }
    
    func testNoTypeAnnotationTrivia() {
        assertExpansion(
            of: """
            @Godot(
            .tool) // like this
            class TestClass: Node {     
                /* comment */@Signal/* comment */ var/* comment */ signal/* comment */: /* comment */ SimpleSignal // Comment
                @Callable/* comment */
                public func /* comment */foo/* comment */(
                    /* can do that too -> */var /* comment */lala: Int // COMMENT            
                ) -> /* comment */ Int // COMMENT
                {
                    0
                }            
            }
            """
        )
    }

    func testRpcMacro() {
        assertExpansion(
            of: """
            @Godot class MultiplayerNode: Node {
                @Callable @Rpc(mode: .anyPeer, transferMode: .reliable)
                func syncPosition(_ position: Vector3) {
                }

                @Callable @Rpc
                func defaultRpc() {
                }

                @Callable @Rpc(mode: .authority, callLocal: true, transferMode: .unreliableOrdered, transferChannel: 2)
                func fullConfig() {
                }
            }
            """
        )
    }

    func testRpcMacroNotOnFunction() {
        assertExpansion(
            of: """
            @Godot class MultiplayerNode: Node {
                @Rpc
                var notAFunction: Int = 0
            }
            """,
            diagnostics: [.init(message: "@Rpc attribute can only be applied to functions", line: 2, column: 5)]
        )
    }

}
