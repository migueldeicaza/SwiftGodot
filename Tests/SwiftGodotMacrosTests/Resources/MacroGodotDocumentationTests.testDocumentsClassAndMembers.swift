/// A player-controlled character.
///
/// Moves with ``speed`` and emits ``jumped`` when it leaves the ground.
class Player: CharacterBody3D {
    /// Walking speed, in meters per second.
    var speed: Double = 2

    static func _mproxy_set_speed(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling setter for speed: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        SwiftGodotRuntime._invokeSetter(arguments, "speed", object.speed) {
            object.speed = $0
        }
        return nil
    }

    static func _mproxy_get_speed(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling getter for speed: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return SwiftGodotRuntime._invokeGetter(object.speed)
    }

    /// Not documented in Godot, because it is not exported.
    var internalState = 0

    /// Makes the player jump.
    ///
    /// - Parameter height: How high to jump, in meters.
    /// - Returns: Whether the jump started.
    func jump(height: Double) -> Bool { true }

    static func _mproxy_jump(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `jump`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Double.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.jump(height: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `jump`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_jump(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `jump`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Double = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.jump(height: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `jump`: \(String(describing: error))")                    
        }
    }

    /// Emitted when the player leaves the ground.
    var jumped: SimpleSignal {
        get {
            SimpleSignal(target: self, signalName: "jumped")
        }
    }

    enum Gait: Int, CaseIterable {
        /// Slow and quiet.
        case walk
        /// Fast and loud.
        case run
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass()
    }

    private static func _initializeClass() {
        guard swiftGodotShouldInitializeClass(type: Player.self) else {
            return
        }
        let className = StringName("Player")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerPropertyWithGetterSetter(
            className: className,
            info: SwiftGodotRuntime._propInfo(
                at: \Player.speed,
                name: "speed",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_speed",
            setterName: "set_speed",
            getterFunction: Player._mproxy_get_speed,
            setterFunction: Player._mproxy_set_speed
        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "jump",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Bool.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Double.self, name: "height")
            ],
            function: Player._mproxy_jump,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Player._pproxy_jump (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SimpleSignal.register(as: "jumped", in: className, names: [])
        SwiftGodotRuntime._registerEnumIfPossible(Player.Gait.self)
    }

    override open class var _editorDocumentation: String? {
        #if SWIFTGODOT_INCLUDE_EDITOR_DOCUMENTATION
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<class name=\"Player\">\n<brief_description>A player-controlled character.</brief_description>\n<description>Moves with [member speed] and emits [signal jumped] when it leaves the ground.</description>\n<methods>\n<method name=\"jump\"><description>Makes the player jump.\n[b]Parameters:[/b]\n- [param height]: How high to jump, in meters.\n[b]Returns:[/b] Whether the jump started.</description></method>\n</methods>\n<members>\n<member name=\"speed\" type=\"\">Walking speed, in meters per second.</member>\n</members>\n<signals>\n<signal name=\"jumped\"><description>Emitted when the player leaves the ground.</description></signal>\n</signals>\n<constants>\n<constant name=\"walk\" value=\"\">Slow and quiet.</constant>\n<constant name=\"run\" value=\"\">Fast and loud.</constant>\n</constants>\n</class>\n"
        #else
        return nil
        #endif
    }
}
