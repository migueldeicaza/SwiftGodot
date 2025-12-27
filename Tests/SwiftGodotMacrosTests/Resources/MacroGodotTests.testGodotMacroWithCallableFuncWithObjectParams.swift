class Castro: Node {
    func deleteEpisode() {}

    static func _mproxy_deleteEpisode(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `deleteEpisode`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodotRuntime._wrapCallableResult(object.deleteEpisode())

    }
    static func _pproxy_deleteEpisode(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
            SwiftGodotRuntime.GD.printErr("Error calling `deleteEpisode`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.deleteEpisode()) 

    }
    func subscribe(podcast: Podcast) {}

    static func _mproxy_subscribe(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `subscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.subscribe(podcast: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `subscribe`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_subscribe(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `subscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Podcast = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.subscribe(podcast: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `subscribe`: \(String(describing: error))")                    
        }
    }
    func perhapsSubscribe(podcast: Podcast?) {}

    static func _mproxy_perhapsSubscribe(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `perhapsSubscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast?.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.perhapsSubscribe(podcast: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `perhapsSubscribe`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_perhapsSubscribe(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `perhapsSubscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Podcast? = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.perhapsSubscribe(podcast: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `perhapsSubscribe`: \(String(describing: error))")                    
        }
    }
    func removeSilences(from: Variant) {}

    static func _mproxy_removeSilences(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `removeSilences`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Variant.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.removeSilences(from: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `removeSilences`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_removeSilences(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `removeSilences`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Variant = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.removeSilences(from: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `removeSilences`: \(String(describing: error))")                    
        }
    }
    func getLatestEpisode(podcast: Podcast) -> Episode {}

    static func _mproxy_getLatestEpisode(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `getLatestEpisode`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodotRuntime._wrapCallableResult(object.getLatestEpisode(podcast: arg0))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `getLatestEpisode`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_getLatestEpisode(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `getLatestEpisode`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Podcast = try rargs.fetchArgument(at: 0)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.getLatestEpisode(podcast: arg0)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `getLatestEpisode`: \(String(describing: error))")                    
        }
    }
    func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}

    static func _mproxy_queue(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodotRuntime.Arguments) -> SwiftGodotRuntime.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `queue`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            let arg1 = try arguments.argument(ofType: Podcast.self, at: 1)
            return SwiftGodotRuntime._wrapCallableResult(object.queue(arg0, after: arg1))

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `queue`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_queue(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: SwiftGodotRuntime.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = SwiftGodotRuntime._unwrap(self, pInstance: pInstance) else {
                SwiftGodotRuntime.GD.printErr("Error calling `queue`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Podcast = try rargs.fetchArgument(at: 0)
        let arg1: Podcast = try rargs.fetchArgument(at: 1)
            SwiftGodotRuntime.RawReturnWriter.writeResult(returnValue, object.queue(arg0, after: arg1)) 

        } catch {
            SwiftGodotRuntime.GD.printErr("Error calling `queue`: \(String(describing: error))")                    
        }
    }

    override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Castro")
        if classInitializationLevel.rawValue >= GDExtension.InitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "deleteEpisode",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: Castro._mproxy_deleteEpisode,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_deleteEpisode (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "subscribe",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_subscribe,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_subscribe (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "perhapsSubscribe",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Podcast?.self, name: "podcast")
            ],
            function: Castro._mproxy_perhapsSubscribe,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_perhapsSubscribe (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "removeSilences",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Variant.self, name: "from")
            ],
            function: Castro._mproxy_removeSilences,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_removeSilences (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "getLatestEpisode",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Episode.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_getLatestEpisode,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_getLatestEpisode (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        SwiftGodotRuntime._registerMethod(
            className: className,
            name: "queue",
            flags: .default,
            returnValue: SwiftGodotRuntime._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodotRuntime._argumentPropInfo(Podcast.self, name: "podcast"),
                SwiftGodotRuntime._argumentPropInfo(Podcast.self, name: "preceedingPodcast")
            ],
            function: Castro._mproxy_queue,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    GD.print("Godot is not passing the arguments");
                    return
                }
                Castro._pproxy_queue (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }()
}
