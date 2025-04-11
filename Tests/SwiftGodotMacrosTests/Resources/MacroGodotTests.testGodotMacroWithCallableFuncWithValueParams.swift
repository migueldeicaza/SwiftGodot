class MathHelper: Node {
    func multiply(_ a: Int, by b: Int) -> Int { a * b}

    func _mproxy_multiply(arguments: borrowing Arguments) -> Variant? {
        do { // safe arguments access scope
            let arg0: Int = try arguments.argument(ofType: Int.self, at: 0)
            let arg1: Int = try arguments.argument(ofType: Int.self, at: 1)
            let result = multiply(arg0, by: arg1)
            return Variant(result)

        } catch let error as ArgumentAccessError {
            GD.printErr(error.description)
            return nil
        } catch {
            GD.printErr("Error calling `multiply`: \(error)")
            return nil
        }
    }
    func divide(_ a: Float, by b: Float) -> Float { a / b }

    func _mproxy_divide(arguments: borrowing Arguments) -> Variant? {
        do { // safe arguments access scope
            let arg0: Float = try arguments.argument(ofType: Float.self, at: 0)
            let arg1: Float = try arguments.argument(ofType: Float.self, at: 1)
            let result = divide(arg0, by: arg1)
            return Variant(result)

        } catch let error as ArgumentAccessError {
            GD.printErr(error.description)
            return nil
        } catch {
            GD.printErr("Error calling `divide`: \(error)")
            return nil
        }
    }
    func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }

    func _mproxy_areBothTrue(arguments: borrowing Arguments) -> Variant? {
        do { // safe arguments access scope
            let arg0: Bool = try arguments.argument(ofType: Bool.self, at: 0)
            let arg1: Bool = try arguments.argument(ofType: Bool.self, at: 1)
            let result = areBothTrue(arg0, and: arg1)
            return Variant(result)

        } catch let error as ArgumentAccessError {
            GD.printErr(error.description)
            return nil
        } catch {
            GD.printErr("Error calling `areBothTrue`: \(error)")
            return nil
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("MathHelper")
        assert(ClassDB.classExists(class: className))
        let prop_0 = PropInfo (propertyType: .int, propertyName: "", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        let prop_1 = PropInfo (propertyType: .int, propertyName: "a", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        let prop_2 = PropInfo (propertyType: .int, propertyName: "b", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        let multiplyArgs = [
            prop_1,
            prop_2,
        ]
        let classInfo = ClassInfo<MathHelper> (name: className)
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