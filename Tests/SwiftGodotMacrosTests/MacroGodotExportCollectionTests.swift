import MacroTesting
import XCTest

final class MacroGodotExportCollectionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testExportArrayStringGodotMacroFails() {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                @Export var greetings: [String]
            }
            """
        } diagnostics: {
            """
            @Godot
            ╰─ 🛑 @Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead
            class SomeNode: Node {
                @Export var greetings: [String]
                ┬──────────────────────────────
                ╰─ 🛑 @Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead
            }
            """
        }
    }
	
    func testExportArrayStringMacroFails() {
        assertMacro {
            """
            @Export
            var greetings: [String]
            """
        } diagnostics: {
            """
            @Export
            ╰─ 🛑 @Export attribute can not be applied to Array types, use a VariantCollection, or an ObjectCollection instead
            var greetings: [String]
            """
        }
    }

    func testExportGenericArrayStringGodotMacro() {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                @Export
                var greetings: VariantCollection<String> = []
            }
            """
        } expansion: {
            """
            class SomeNode: Node {
                var greetings: VariantCollection<String> = []

                func _mproxy_get_greetings(args: [Variant]) -> Variant? {
                	return Variant(greetings.array)
                }

                func _mproxy_set_greetings(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(String.self)) else {
                		return nil
                	}
                	greetings.array = gArray
                	return nil
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _pgreetings = PropInfo (
                        propertyType: .array,
                        propertyName: "greetings",
                        className: StringName("Array[String]"),
                        hint: .arrayType,
                        hintStr: "String",
                        usage: .default)
                	classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
                	classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
                	classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
                } ()
            }
            """
        }
    }
	
    func testExportArrayStringMacro() {
        assertMacro {
            """
            @Export var greetings: VariantCollection<String> = []
            """
        } expansion: {
            """
            var greetings: VariantCollection<String> = []

            func _mproxy_get_greetings(args: [Variant]) -> Variant? {
            	return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: [Variant]) -> Variant? {
            	guard let arg = args.first,
            		  let gArray = GArray(arg),
            		  gArray.isTyped(),
            		  gArray.isSameTyped(array: GArray(String.self)) else {
            		return nil
            	}
            	greetings.array = gArray
            	return nil
            }
            """
        }
    }
	
	func testExportGenericArrayStringMacro() {
            assertMacro {
                """
                @Export var greetings: VariantCollection<String> = []
                """
            } expansion: {
                """
                var greetings: VariantCollection<String> = []

                func _mproxy_get_greetings(args: [Variant]) -> Variant? {
                	return Variant(greetings.array)
                }

                func _mproxy_set_greetings(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(String.self)) else {
                		return nil
                	}
                	greetings.array = gArray
                	return nil
                }
                """
            }
	}
	
	func testExportConstantGenericArrayStringMacro() {
            assertMacro {
                """
                @Export let greetings: VariantCollection<String> = []
                """
            } expansion: {
                """
                let greetings: VariantCollection<String> = []

                func _mproxy_get_greetings(args: [Variant]) -> Variant? {
                	return Variant(greetings.array)
                }

                func _mproxy_set_greetings(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(String.self)) else {
                		return nil
                	}
                	greetings.array = gArray
                	return nil
                }
                """
            }
	}
	
	func testExportOptionalGenericArrayStringMacro() {
            assertMacro {
                """
                @Export var greetings: VariantCollection<String>? = []
                """
            } diagnostics: {
                """
                @Export var greetings: VariantCollection<String>? = []
                ┬──────
                ╰─ 🛑 @Export optional Collections are not supported
                """
            }
	}
	
    func testExportGArray() {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                @Export var someArray: GArray = GArray()
            }
            """
        } expansion: {
            """
            class SomeNode: Node {
                var someArray: GArray = GArray()

                func _mproxy_set_someArray (args: [Variant]) -> Variant? {
                	guard let arg = args.first else {
                		return nil
                	}
                	if let value = GArray (arg) {
                		self.someArray = value
                	} else {
                		GD.printErr ("Unable to set `someArray` value: ", arg)
                	}
                	return nil
                }

                func _mproxy_get_someArray (args: [Variant]) -> Variant? {
                    return Variant (someArray)
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeArray = PropInfo (
                        propertyType: .array,
                        propertyName: "someArray",
                        className: className,
                        hint: .none,
                        hintStr: "",
                        usage: .default)
                	classInfo.registerMethod (name: "_mproxy_get_someArray", flags: .default, returnValue: _psomeArray, arguments: [], function: SomeNode._mproxy_get_someArray)
                	classInfo.registerMethod (name: "_mproxy_set_someArray", flags: .default, returnValue: nil, arguments: [_psomeArray], function: SomeNode._mproxy_set_someArray)
                	classInfo.registerProperty (_psomeArray, getter: "_mproxy_get_someArray", setter: "_mproxy_set_someArray")
                } ()
            }
            """
        }
    }
    
    func testExportArrayIntGodotMacro() {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
            }
            """
        } expansion: {
            """
            class SomeNode: Node {
                var someNumbers: VariantCollection<Int> = []

                func _mproxy_get_someNumbers(args: [Variant]) -> Variant? {
                	return Variant(someNumbers.array)
                }

                func _mproxy_set_someNumbers(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(Int.self)) else {
                		return nil
                	}
                	someNumbers.array = gArray
                	return nil
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                	classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
                	classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
                	classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
                } ()
            }
            """
        }
    }

    func testExportArraysIntGodotMacro() throws {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                @Export var someNumbers: VariantCollection<Int> = []
                @Export var someOtherNumbers: VariantCollection<Int> = []
            }
            """
        } expansion: {
            """
            class SomeNode: Node {
                var someNumbers: VariantCollection<Int> = []

                func _mproxy_get_someNumbers(args: [Variant]) -> Variant? {
                	return Variant(someNumbers.array)
                }

                func _mproxy_set_someNumbers(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(Int.self)) else {
                		return nil
                	}
                	someNumbers.array = gArray
                	return nil
                }
                var someOtherNumbers: VariantCollection<Int> = []

                func _mproxy_get_someOtherNumbers(args: [Variant]) -> Variant? {
                	return Variant(someOtherNumbers.array)
                }

                func _mproxy_set_someOtherNumbers(args: [Variant]) -> Variant? {
                	guard let arg = args.first,
                		  let gArray = GArray(arg),
                		  gArray.isTyped(),
                		  gArray.isSameTyped(array: GArray(Int.self)) else {
                		return nil
                	}
                	someOtherNumbers.array = gArray
                	return nil
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _psomeNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                	classInfo.registerMethod (name: "get_some_numbers", flags: .default, returnValue: _psomeNumbers, arguments: [], function: SomeNode._mproxy_get_someNumbers)
                	classInfo.registerMethod (name: "set_some_numbers", flags: .default, returnValue: nil, arguments: [_psomeNumbers], function: SomeNode._mproxy_set_someNumbers)
                	classInfo.registerProperty (_psomeNumbers, getter: "get_some_numbers", setter: "set_some_numbers")
                    let _psomeOtherNumbers = PropInfo (
                        propertyType: .array,
                        propertyName: "some_other_numbers",
                        className: StringName("Array[int]"),
                        hint: .arrayType,
                        hintStr: "int",
                        usage: .default)
                	classInfo.registerMethod (name: "get_some_other_numbers", flags: .default, returnValue: _psomeOtherNumbers, arguments: [], function: SomeNode._mproxy_get_someOtherNumbers)
                	classInfo.registerMethod (name: "set_some_other_numbers", flags: .default, returnValue: nil, arguments: [_psomeOtherNumbers], function: SomeNode._mproxy_set_someOtherNumbers)
                	classInfo.registerProperty (_psomeOtherNumbers, getter: "get_some_other_numbers", setter: "set_some_other_numbers")
                } ()
            }
            """
        }
    }

    func testGodotExportTwoStringArrays() throws {
        assertMacro {
            """
            import SwiftGodot

            @Godot
            class ArrayTest: Node {
               @Export var firstNames: VariantCollection<String> = ["Thelonius"]
               @Export var lastNames: VariantCollection<String> = ["Monk"]
            }
            """
        } expansion: {
            """
            import SwiftGodot
            class ArrayTest: Node {
               var firstNames: VariantCollection<String> = ["Thelonius"]

               func _mproxy_get_firstNames(args: [Variant]) -> Variant? {
               	return Variant(firstNames.array)
               }

               func _mproxy_set_firstNames(args: [Variant]) -> Variant? {
               	guard let arg = args.first,
               		  let gArray = GArray(arg),
               		  gArray.isTyped(),
               		  gArray.isSameTyped(array: GArray(String.self)) else {
               		return nil
               	}
               	firstNames.array = gArray
               	return nil
               }
               var lastNames: VariantCollection<String> = ["Monk"]

               func _mproxy_get_lastNames(args: [Variant]) -> Variant? {
               	return Variant(lastNames.array)
               }

               func _mproxy_set_lastNames(args: [Variant]) -> Variant? {
               	guard let arg = args.first,
               		  let gArray = GArray(arg),
               		  gArray.isTyped(),
               		  gArray.isSameTyped(array: GArray(String.self)) else {
               		return nil
               	}
               	lastNames.array = gArray
               	return nil
               }

               override open class var classInitializer: Void {
                   let _ = super.classInitializer
                   return _initializeClass
               }

               private static let _initializeClass: Void = {
                   let className = StringName("ArrayTest")
                   assert(ClassDB.classExists(class: className))
                   let classInfo = ClassInfo<ArrayTest> (name: className)
                   let _pfirstNames = PropInfo (
                       propertyType: .array,
                       propertyName: "first_names",
                       className: StringName("Array[String]"),
                       hint: .arrayType,
                       hintStr: "String",
                       usage: .default)
               	classInfo.registerMethod (name: "get_first_names", flags: .default, returnValue: _pfirstNames, arguments: [], function: ArrayTest._mproxy_get_firstNames)
               	classInfo.registerMethod (name: "set_first_names", flags: .default, returnValue: nil, arguments: [_pfirstNames], function: ArrayTest._mproxy_set_firstNames)
               	classInfo.registerProperty (_pfirstNames, getter: "get_first_names", setter: "set_first_names")
                   let _plastNames = PropInfo (
                       propertyType: .array,
                       propertyName: "last_names",
                       className: StringName("Array[String]"),
                       hint: .arrayType,
                       hintStr: "String",
                       usage: .default)
               	classInfo.registerMethod (name: "get_last_names", flags: .default, returnValue: _plastNames, arguments: [], function: ArrayTest._mproxy_get_lastNames)
               	classInfo.registerMethod (name: "set_last_names", flags: .default, returnValue: nil, arguments: [_plastNames], function: ArrayTest._mproxy_set_lastNames)
               	classInfo.registerProperty (_plastNames, getter: "get_last_names", setter: "set_last_names")
               } ()
            }
            """
        }
    }

    func testExportObjectCollection() throws {
        assertMacro {
            """
            @Export var greetings: ObjectCollection<Node3D> = []
            """
        } expansion: {
            """
            var greetings: ObjectCollection<Node3D> = []

            func _mproxy_get_greetings(args: [Variant]) -> Variant? {
            	return Variant(greetings.array)
            }

            func _mproxy_set_greetings(args: [Variant]) -> Variant? {
            	guard let arg = args.first,
            		  let gArray = GArray(arg),
            		  gArray.isTyped(),
            		  gArray.isSameTyped(array: GArray(Node3D.self)) else {
            		return nil
            	}
            	greetings.array = gArray
            	return nil
            }
            """
        }
    }

    func testGodotExportObjectCollection() throws {
        assertMacro {
            """
            @Godot
            class SomeNode: Node {
                    @Export var greetings: ObjectCollection<Node3D> = []
            }
            """
        } expansion: {
            """
            class SomeNode: Node {
                    var greetings: ObjectCollection<Node3D> = []

                    func _mproxy_get_greetings(args: [Variant]) -> Variant? {
                    	return Variant(greetings.array)
                    }

                    func _mproxy_set_greetings(args: [Variant]) -> Variant? {
                    	guard let arg = args.first,
                    		  let gArray = GArray(arg),
                    		  gArray.isTyped(),
                    		  gArray.isSameTyped(array: GArray(Node3D.self)) else {
                    		return nil
                    	}
                    	greetings.array = gArray
                    	return nil
                    }

                    override open class var classInitializer: Void {
                        let _ = super.classInitializer
                        return _initializeClass
                    }

                    private static let _initializeClass: Void = {
                        let className = StringName("SomeNode")
                        assert(ClassDB.classExists(class: className))
                        let classInfo = ClassInfo<SomeNode> (name: className)
                        let _pgreetings = PropInfo (
                            propertyType: .array,
                            propertyName: "greetings",
                            className: StringName("Array[Node3D]"),
                            hint: .arrayType,
                            hintStr: "Node3D",
                            usage: .default)
                    	classInfo.registerMethod (name: "get_greetings", flags: .default, returnValue: _pgreetings, arguments: [], function: SomeNode._mproxy_get_greetings)
                    	classInfo.registerMethod (name: "set_greetings", flags: .default, returnValue: nil, arguments: [_pgreetings], function: SomeNode._mproxy_set_greetings)
                    	classInfo.registerProperty (_pgreetings, getter: "get_greetings", setter: "set_greetings")
                    } ()
            }
            """
        }
    }
}
