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
		"Export": GodotExport.self
    ]
    
    func testGodotMacro() {
        assertMacroExpansion(
            """
            @Godot class Hi: Node {
            }
            """,
            expandedSource: """
            class Hi: Node {

                required init(nativeHandle _: UnsafeRawPointer) {
                	fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
                }

                required init() {
                	_ = Hi._initClass
                	super.init ()
                }

                static var _initClass: Void = {
                    let className = StringName("Hi")
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()
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
            
                required init(nativeHandle _: UnsafeRawPointer) {
                	fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
                }

                required init() {
                	_ = Hi._initClass
                	super.init ()
                }

                static var _initClass: Void = {
                    let className = StringName("Hi")
                    let classInfo = ClassInfo<Hi> (name: className)
                } ()
            }
            """,
			macros: testMacros
		)
	}
	
	func testGodotMacroWithCallableFunc() {
		// Note when editing: Xcode loves to change all indentation to be consistent as either tabs or spaces, but the macro expansion produces a mix.
		// I had to set Settings->Text Editing->Tab Key to "Inserts a Tab Character" in order to resolve this.
		assertMacroExpansion(
			"""
			@Godot class Castro: Node {
				@Callable func deleteEpisode() {
				}
			}
			""",
            expandedSource: """
            class Castro: Node {
            	func deleteEpisode() {
            	}
            
            	func _mproxy_deleteEpisode (args: [Variant]) -> Variant? {
            		deleteEpisode ()
            		return nil
            	}
            
                required init(nativeHandle _: UnsafeRawPointer) {
                	fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
                }

                required init() {
                	_ = Castro._initClass
                	super.init ()
                }

                static var _initClass: Void = {
                    let className = StringName("Castro")
                    let classInfo = ClassInfo<Castro> (name: className)
                	classInfo.registerMethod(name: StringName("deleteEpisode"), flags: .default, returnValue: nil, arguments: [], function: Castro._mproxy_deleteEpisode)
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
            		return nil
            	}
            
            	func _mproxy_get_goodName (args: [Variant]) -> Variant? {
            	    return Variant (goodName)
            	}
            
                required init(nativeHandle _: UnsafeRawPointer) {
                	fatalError("init(nativeHandle:) called, it is a sign that something is wrong, as these objects should not be re-hydrated")
                }
            
                required init() {
                	_ = Hi._initClass
                	super.init ()
                }
            
                static var _initClass: Void = {
                    let className = StringName("Hi")
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
