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

// Note when editing: Xcode loves to change all indentation to be consistent as either tabs or spaces, but the macro expansion produces a mix.
// I had to set Settings->Text Editing->Tab Key to "Inserts a Tab Character" in order to resolve this.
// "Paste and Preserve Formatting" was also helpful.

final class MacroGodotTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "Godot": GodotMacro.self,
		"Callable": GodotCallable.self,
		"Export": GodotExport.self,
        "signal": SignalMacro.self
    ]
    
    func testGodotMacro() {
        assertMacroExpansion(
            """
            @Godot class Hi: Node {
            }
            """,
            expandedSource: """
            class Hi: Node {
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()
            }
            """,
            macros: testMacros
        )
    }

    func testGodotMacroWithFinalClass() {
        assertMacroExpansion(
            """
            @Godot final class Hi: Node {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """,
            expandedSource: """
            final class Hi: Node {
                override func _hasPoint(_ point: Vector2) -> Bool { false }

                override public class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()

                override public class func implementedOverrides() -> [StringName] {
                    super.implementedOverrides() + [
                    	StringName("_has_point"),
                    ]
                }
            }
            """,
            macros: testMacros
        )
    }

    func testGodotVirtualMethodsMacro() {
        assertMacroExpansion(
            """
            @Godot class Hi: Control {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """,
            expandedSource: """
            class Hi: Control {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()
            
                override open class func implementedOverrides() -> [StringName] {
                    super.implementedOverrides() + [
                    	StringName("_has_point"),
                    ]
                }
            }
            """,
            macros: testMacros
        )
    }
	
	func testGodotMacroWithNonCallableFunc() {
		// Note when editing: Xcode loves to change all indentation to be consistent as either tabs or spaces, but the macro expansion produces a mix.
		// I had to set Settings->Text Editing->Tab Key to "Inserts a Tab Character" in order to resolve this.
		assertMacroExpansion(
			"""
			@Godot class Hi: Node {
				func hi() {
				}
			}
			""",
            expandedSource: """
            class Hi: Node {
            	func hi() {
            	}
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()
            }
            """,
			macros: testMacros
		)
	}
    func testGodotMacroStaticSignal() {
        // Note when editing: Xcode loves to change all indentation to be consistent as either tabs or spaces, but the macro expansion produces a mix.
        // I had to set Settings->Text Editing->Tab Key to "Inserts a Tab Character" in order to resolve this.
        assertMacroExpansion(
            """
            @Godot class Hi: Node {
                #signal("picked_up_item", arguments: ["kind": String.self])
                #signal("scored")
                #signal("different_init", arguments: [:])
                #signal("different_init2", arguments: .init())
            }
            """,
            expandedSource: """
            class Hi: Node {
                static let pickedUpItem = SignalWith1Argument<String>("picked_up_item", argument1Name: "kind")
                static let scored = SignalWithNoArguments("scored")
                static let differentInit = SignalWithNoArguments("different_init")
                static let differentInit2 = SignalWithNoArguments("different_init2")

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                    classInfo.registerSignal(name: Hi.pickedUpItem.name, arguments: Hi.pickedUpItem.arguments)
                    classInfo.registerSignal(name: Hi.scored.name, arguments: Hi.scored.arguments)
                    classInfo.registerSignal(name: Hi.differentInit.name, arguments: Hi.differentInit.arguments)
                    classInfo.registerSignal(name: Hi.differentInit2.name, arguments: Hi.differentInit2.arguments)
                } ()
            }
            """,
            macros: testMacros
        )
    }
	
	func testGodotMacroWithCallableFuncWithObjectParams() {
		// Note when editing: Xcode loves to change all indentation to be consistent as either tabs or spaces, but the macro expansion produces a mix.
		// I had to set Settings->Text Editing->Tab Key to "Inserts a Tab Character" in order to resolve this.
		assertMacroExpansion(
            """
            @Godot class Castro: Node {
                @Callable func deleteEpisode() {}
                @Callable func subscribe(podcast: Podcast) {}
                @Callable func removeSilences(from: Variant) {}
                @Callable func getLatestEpisode(podcast: Podcast) -> Episode {}
                @Callable func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}
            }
            """,
            expandedSource:
                """
                class Castro: Node {
                    func deleteEpisode() {}

                    func _mproxy_deleteEpisode (args: [Variant]) -> Variant? {
                    	deleteEpisode ()
                    	return nil
                    }
                    func subscribe(podcast: Podcast) {}

                    func _mproxy_subscribe (args: [Variant]) -> Variant? {
                    	subscribe (podcast: Podcast.makeOrUnwrap (args [0])!)
                    	return nil
                    }
                    func removeSilences(from: Variant) {}

                    func _mproxy_removeSilences (args: [Variant]) -> Variant? {
                    	removeSilences (from: args [0])
                    	return nil
                    }
                    func getLatestEpisode(podcast: Podcast) -> Episode {}

                    func _mproxy_getLatestEpisode (args: [Variant]) -> Variant? {
                    	let result = getLatestEpisode (podcast: Podcast.makeOrUnwrap (args [0])!)
                    	return Variant (result)
                    }
                    func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}

                    func _mproxy_queue (args: [Variant]) -> Variant? {
                    	queue (Podcast.makeOrUnwrap (args [0])!, after: Podcast.makeOrUnwrap (args [1])!)
                    	return nil
                    }

                    override open class var classInitializer: Void {
                        let _ = super.classInitializer
                        return _initializeClass
                    }

                    private static var _initializeClass: Void = {
                        let className = StringName("Castro")
                        assert(ClassDB.classExists(class: className))
                        let classInfo = ClassInfo<Castro> (name: className)
                    	classInfo.registerMethod(name: StringName("deleteEpisode"), flags: .default, returnValue: nil, arguments: [], function: Castro._mproxy_deleteEpisode)
                    	let prop_0 = PropInfo (propertyType: .object, propertyName: "podcast", className: StringName("Podcast"), hint: .none, hintStr: "", usage: .default)
                    	let subscribeArgs = [
                    		prop_0,
                    	]
                    	classInfo.registerMethod(name: StringName("subscribe"), flags: .default, returnValue: nil, arguments: subscribeArgs, function: Castro._mproxy_subscribe)
                    	let prop_1 = PropInfo (propertyType: .object, propertyName: "from", className: StringName("Variant"), hint: .none, hintStr: "", usage: .default)
                    	let removeSilencesArgs = [
                    		prop_1,
                    	]
                    	classInfo.registerMethod(name: StringName("removeSilences"), flags: .default, returnValue: nil, arguments: removeSilencesArgs, function: Castro._mproxy_removeSilences)
                    	let prop_2 = PropInfo (propertyType: .object, propertyName: "", className: StringName("Episode"), hint: .none, hintStr: "", usage: .default)
                    	let getLatestEpisodeArgs = [
                    		prop_0,
                    	]
                    	classInfo.registerMethod(name: StringName("getLatestEpisode"), flags: .default, returnValue: prop_2, arguments: getLatestEpisodeArgs, function: Castro._mproxy_getLatestEpisode)
                    	let prop_3 = PropInfo (propertyType: .object, propertyName: "preceedingPodcast", className: StringName("Podcast"), hint: .none, hintStr: "", usage: .default)
                    	let queueArgs = [
                    		prop_0,
                    		prop_3,
                    	]
                    	classInfo.registerMethod(name: StringName("queue"), flags: .default, returnValue: nil, arguments: queueArgs, function: Castro._mproxy_queue)
                    } ()
                }
                """,
			macros: testMacros
		)
	}
    
    func testWarningAvoidance() {
        assertMacroExpansion(
            """
            @Godot
            final class MyData: Resource {}
            
            @Godot
            final class MyClass: Node {
                @Export var data: MyData = .init()
            }
            """,
            expandedSource:
            """
            final class MyData: Resource {

                override public class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static var _initializeClass: Void = {
                    let className = StringName("MyData")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<MyData> (name: className)
                } ()}
            final class MyClass: Node {
                var data: MyData = .init()

                func _mproxy_set_data (args: [Variant]) -> Variant? {
                    func dynamicCast<T, U>(_ value: T, as type: U.Type) -> U? {
                        value as? U
                    }
                    let oldRef = dynamicCast (data, as: RefCounted.self)
                    if let res: MyData = args [0].asObject () {
                        dynamicCast (res, as: RefCounted.self)?.reference()
                        data = res
                    }
                    oldRef?.unreference()
                	return nil
                }

                func _mproxy_get_data (args: [Variant]) -> Variant? {
                    return Variant (data)
                }

                override public class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static var _initializeClass: Void = {
                    let className = StringName("MyClass")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<MyClass> (name: className)
                    let _pdata = PropInfo (
                        propertyType: .object,
                        propertyName: "data",
                        className: className,
                        hint: .none,
                        hintStr: "",
                        usage: .default)
                	classInfo.registerMethod (name: "_mproxy_get_data", flags: .default, returnValue: _pdata, arguments: [], function: MyClass._mproxy_get_data)
                	classInfo.registerMethod (name: "_mproxy_set_data", flags: .default, returnValue: nil, arguments: [_pdata], function: MyClass._mproxy_set_data)
                	classInfo.registerProperty (_pdata, getter: "_mproxy_get_data", setter: "_mproxy_set_data")
                } ()
            }
            """,
            macros: testMacros
        )
    }
    
    func testGodotMacroWithCallableFuncWithValueParams() {
        assertMacroExpansion(
            """
            @Godot class MathHelper: Node {
                @Callable func multiply(_ a: Int, by b: Int) -> Int { a * b}
                @Callable func divide(_ a: Float, by b: Float) -> Float { a / b }
                @Callable func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }
            }
            """,
            expandedSource:
                """
                class MathHelper: Node {
                    func multiply(_ a: Int, by b: Int) -> Int { a * b}

                    func _mproxy_multiply (args: [Variant]) -> Variant? {
                    	let result = multiply (Int.makeOrUnwrap (args [0])!, by: Int.makeOrUnwrap (args [1])!)
                    	return Variant (result)
                    }
                    func divide(_ a: Float, by b: Float) -> Float { a / b }

                    func _mproxy_divide (args: [Variant]) -> Variant? {
                    	let result = divide (Float.makeOrUnwrap (args [0])!, by: Float.makeOrUnwrap (args [1])!)
                    	return Variant (result)
                    }
                    func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }

                    func _mproxy_areBothTrue (args: [Variant]) -> Variant? {
                    	let result = areBothTrue (Bool.makeOrUnwrap (args [0])!, and: Bool.makeOrUnwrap (args [1])!)
                    	return Variant (result)
                    }

                    override open class var classInitializer: Void {
                        let _ = super.classInitializer
                        return _initializeClass
                    }

                    private static var _initializeClass: Void = {
                        let className = StringName("MathHelper")
                        assert(ClassDB.classExists(class: className))
                        let classInfo = ClassInfo<MathHelper> (name: className)
                    	let prop_0 = PropInfo (propertyType: .int, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_1 = PropInfo (propertyType: .int, propertyName: "a", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_2 = PropInfo (propertyType: .int, propertyName: "b", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let multiplyArgs = [
                    		prop_1,
                    		prop_2,
                    	]
                    	classInfo.registerMethod(name: StringName("multiply"), flags: .default, returnValue: prop_0, arguments: multiplyArgs, function: MathHelper._mproxy_multiply)
                    	let prop_3 = PropInfo (propertyType: .float, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_4 = PropInfo (propertyType: .float, propertyName: "a", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_5 = PropInfo (propertyType: .float, propertyName: "b", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let divideArgs = [
                    		prop_4,
                    		prop_5,
                    	]
                    	classInfo.registerMethod(name: StringName("divide"), flags: .default, returnValue: prop_3, arguments: divideArgs, function: MathHelper._mproxy_divide)
                    	let prop_6 = PropInfo (propertyType: .bool, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_7 = PropInfo (propertyType: .bool, propertyName: "a", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let prop_8 = PropInfo (propertyType: .bool, propertyName: "b", className: StringName(""), hint: .none, hintStr: "", usage: .default)
                    	let areBothTrueArgs = [
                    		prop_7,
                    		prop_8,
                    	]
                    	classInfo.registerMethod(name: StringName("areBothTrue"), flags: .default, returnValue: prop_6, arguments: areBothTrueArgs, function: MathHelper._mproxy_areBothTrue)
                    } ()
                }
                """,
			macros: testMacros
		)
    }
	
	func testExportGodotMacro() {
		assertMacroExpansion(
			"""
			@Godot class Hi: Node {
				@Export var goodName: String = "Supertop"
			}
			""",
			expandedSource:
            """
            class Hi: Node {
            	var goodName: String = "Supertop"
            
            	func _mproxy_set_goodName (args: [Variant]) -> Variant? {
            		goodName = String (args [0])!
            		return nil
            	}
            
            	func _mproxy_get_goodName (args: [Variant]) -> Variant? {
            	    return Variant (goodName)
            	}
            
                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }
            
                private static var _initializeClass: Void = {
                    let className = StringName("Hi")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<Hi> (name: className)
                    let _pgoodName = PropInfo (
                        propertyType: .string,
                        propertyName: "goodName",
                        className: className,
                        hint: .none,
                        hintStr: "",
                        usage: .default)
                	classInfo.registerMethod (name: "_mproxy_get_goodName", flags: .default, returnValue: _pgoodName, arguments: [], function: Hi._mproxy_get_goodName)
                	classInfo.registerMethod (name: "_mproxy_set_goodName", flags: .default, returnValue: nil, arguments: [_pgoodName], function: Hi._mproxy_set_goodName)
                	classInfo.registerProperty (_pgoodName, getter: "_mproxy_get_goodName", setter: "_mproxy_set_goodName")
                } ()
            }
            """,
			macros: testMacros
		)
	}
}
