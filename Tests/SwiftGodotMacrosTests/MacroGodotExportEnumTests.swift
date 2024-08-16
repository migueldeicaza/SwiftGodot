import MacroTesting
import XCTest

final class MacroGodotExportEnumTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: allMacros) {
            super.invokeTest()
        }
    }

    func testExportEnumGodot() {
        assertMacro {
            """
            enum Demo: Int, CaseIterable {
                case first
            }
            enum Demo64: Int64, CaseIterable {
                case first
            }
            @Godot
            class SomeNode: Node {
                @Export(.enum) var demo: Demo
                @Export(.enum) var demo64: Demo64
            }
            """
        } expansion: {
            #"""
            enum Demo: Int, CaseIterable {
                case first
            }
            enum Demo64: Int64, CaseIterable {
                case first
            }
            class SomeNode: Node {
                var demo: Demo

                func _mproxy_set_demo (args: [Variant]) -> Variant? {
                    if let iv = Int (args [0]), let ev = Demo(rawValue: numericCast (iv)) {
                        self.demo = ev
                    }
                	return nil
                }

                func _mproxy_get_demo (args: [Variant]) -> Variant? {
                    return Variant (demo.rawValue)
                }
                var demo64: Demo64

                func _mproxy_set_demo64 (args: [Variant]) -> Variant? {
                    if let iv = Int (args [0]), let ev = Demo64(rawValue: numericCast (iv)) {
                        self.demo64 = ev
                    }
                	return nil
                }

                func _mproxy_get_demo64 (args: [Variant]) -> Variant? {
                    return Variant (demo64.rawValue)
                }

                override open class var classInitializer: Void {
                    let _ = super.classInitializer
                    return _initializeClass
                }

                private static let _initializeClass: Void = {
                    let className = StringName("SomeNode")
                    assert(ClassDB.classExists(class: className))
                    let classInfo = ClassInfo<SomeNode> (name: className)
                    let _pdemo = PropInfo (
                        propertyType: .int,
                        propertyName: "demo",
                        className: className,
                        hint: .enum,
                        hintStr: tryCase (Demo.self),
                        usage: .default)
                	classInfo.registerMethod (name: "_mproxy_get_demo", flags: .default, returnValue: _pdemo, arguments: [], function: SomeNode._mproxy_get_demo)
                	classInfo.registerMethod (name: "_mproxy_set_demo", flags: .default, returnValue: nil, arguments: [_pdemo], function: SomeNode._mproxy_set_demo)
                	classInfo.registerProperty (_pdemo, getter: "_mproxy_get_demo", setter: "_mproxy_set_demo")
                    let _pdemo64 = PropInfo (
                        propertyType: .int,
                        propertyName: "demo64",
                        className: className,
                        hint: .enum,
                        hintStr: tryCase (Demo64.self),
                        usage: .default)
                	classInfo.registerMethod (name: "_mproxy_get_demo64", flags: .default, returnValue: _pdemo64, arguments: [], function: SomeNode._mproxy_get_demo64)
                	classInfo.registerMethod (name: "_mproxy_set_demo64", flags: .default, returnValue: nil, arguments: [_pdemo64], function: SomeNode._mproxy_set_demo64)
                	classInfo.registerProperty (_pdemo64, getter: "_mproxy_get_demo64", setter: "_mproxy_set_demo64")
                    func tryCase <T : RawRepresentable & CaseIterable> (_ type: T.Type) -> GString {
                        GString (type.allCases.map { v in
                            "\(v):\(v.rawValue)"
                        } .joined(separator: ","))
                    }
                    func tryCase <T : RawRepresentable> (_ type: T.Type) -> String {
                        ""
                    }
                } ()
            }
            """#
        }
    }
}
