class MathHelper: Node {
    func multiply(_ a: Int, by b: Int) -> Int { a * b}

    func _mproxy_multiply(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Int.self, at: 0)
            let arg1 = try arguments.argument(ofType: Int.self, at: 1)
            return SwiftGodot._wrapCallableResult(multiply(arg0, by: arg1))

        } catch {
            SwiftGodot.GD.printErr("Error calling `multiply`: \(error.description)")
        }

        return nil
    }
    func divide(_ a: Float, by b: Float) -> Float { a / b }

    func _mproxy_divide(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Float.self, at: 0)
            let arg1 = try arguments.argument(ofType: Float.self, at: 1)
            return SwiftGodot._wrapCallableResult(divide(arg0, by: arg1))

        } catch {
            SwiftGodot.GD.printErr("Error calling `divide`: \(error.description)")
        }

        return nil
    }
    func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }

    func _mproxy_areBothTrue(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Bool.self, at: 0)
            let arg1 = try arguments.argument(ofType: Bool.self, at: 1)
            return SwiftGodot._wrapCallableResult(areBothTrue(arg0, and: arg1))

        } catch {
            SwiftGodot.GD.printErr("Error calling `areBothTrue`: \(error.description)")
        }

        return nil
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
            name: "multiply",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Int.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Int.self, name: "a"),
                SwiftGodot._argumentPropInfo(Int.self, name: "b")
            ],
            function: MathHelper._mproxy_multiply
        )
        classInfo.registerMethod(
            name: "divide",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Float.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Float.self, name: "a"),
                SwiftGodot._argumentPropInfo(Float.self, name: "b")
            ],
            function: MathHelper._mproxy_divide
        )
        classInfo.registerMethod(
            name: "areBothTrue",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Bool.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Bool.self, name: "a"),
                SwiftGodot._argumentPropInfo(Bool.self, name: "b")
            ],
            function: MathHelper._mproxy_areBothTrue
        )
    } ()
}