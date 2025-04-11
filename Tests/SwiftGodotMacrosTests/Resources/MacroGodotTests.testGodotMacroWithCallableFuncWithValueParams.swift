class MathHelper: Node {
    func multiply(_ a: Int, by b: Int) -> Int { a * b}

    func _mproxy_multiply(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Int.self, at: 0)
            let arg1 = try arguments.argument(ofType: Int.self, at: 1)
            return SwiftGodot._macroCallableToVariant(multiply(arg0, by: arg1))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `multiply`: \(error)")
            return nil
        }
    }
    func divide(_ a: Float, by b: Float) -> Float { a / b }

    func _mproxy_divide(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Float.self, at: 0)
            let arg1 = try arguments.argument(ofType: Float.self, at: 1)
            return SwiftGodot._macroCallableToVariant(divide(arg0, by: arg1))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `divide`: \(error)")
            return nil
        }
    }
    func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }

    func _mproxy_areBothTrue(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Bool.self, at: 0)
            let arg1 = try arguments.argument(ofType: Bool.self, at: 1)
            return SwiftGodot._macroCallableToVariant(areBothTrue(arg0, and: arg1))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `areBothTrue`: \(error)")
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
        let classInfo = ClassInfo<MathHelper> (name: className)
        classInfo.registerMethod(
            name: StringName("multiply"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Int.self),
            arguments: [_macroGodotGetCallablePropInfo(Int.self, name: "a"), _macroGodotGetCallablePropInfo(Int.self, name: "b")],
            function: MathHelper._mproxy_multiply
        )
        classInfo.registerMethod(
            name: StringName("divide"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Float.self),
            arguments: [_macroGodotGetCallablePropInfo(Float.self, name: "a"), _macroGodotGetCallablePropInfo(Float.self, name: "b")],
            function: MathHelper._mproxy_divide
        )
        classInfo.registerMethod(
            name: StringName("areBothTrue"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Bool.self),
            arguments: [_macroGodotGetCallablePropInfo(Bool.self, name: "a"), _macroGodotGetCallablePropInfo(Bool.self, name: "b")],
            function: MathHelper._mproxy_areBothTrue
        )
    } ()
}