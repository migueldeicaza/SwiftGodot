class Castro: Node {
    func deleteEpisode() {}

    static func _mproxy_deleteEpisode(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
            SwiftGodot.GD.printErr("Error calling `deleteEpisode`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return SwiftGodot._wrapCallableResult(object.deleteEpisode())

    }
    func subscribe(podcast: Podcast) {}

    static func _mproxy_subscribe(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `subscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.subscribe(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `subscribe`: \(error.description)")
        }

        return nil
    }
    func perhapsSubscribe(podcast: Podcast?) {}

    static func _mproxy_perhapsSubscribe(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `perhapsSubscribe`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast?.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.perhapsSubscribe(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `perhapsSubscribe`: \(error.description)")
        }

        return nil
    }
    func removeSilences(from: Variant) {}

    static func _mproxy_removeSilences(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `removeSilences`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Variant.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.removeSilences(from: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `removeSilences`: \(error.description)")
        }

        return nil
    }
    func getLatestEpisode(podcast: Podcast) -> Episode {}

    static func _mproxy_getLatestEpisode(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `getLatestEpisode`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._wrapCallableResult(object.getLatestEpisode(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `getLatestEpisode`: \(error.description)")
        }

        return nil
    }
    func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}

    static func _mproxy_queue(pInstance: UnsafeRawPointer?, arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.FastVariant? {
        do { // safe arguments access scope
            guard let object = SwiftGodot._unwrap(self, pInstance: pInstance) else {
                SwiftGodot.GD.printErr("Error calling `queue`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            let arg1 = try arguments.argument(ofType: Podcast.self, at: 1)
            return SwiftGodot._wrapCallableResult(object.queue(arg0, after: arg1))

        } catch {
            SwiftGodot.GD.printErr("Error calling `queue`: \(error.description)")
        }

        return nil
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
        SwiftGodot._registerMethod(
            className: className,
            name: "deleteEpisode",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [

            ],
            function: Castro._mproxy_deleteEpisode
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "subscribe",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_subscribe
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "perhapsSubscribe",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast?.self, name: "podcast")
            ],
            function: Castro._mproxy_perhapsSubscribe
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "removeSilences",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Variant.self, name: "from")
            ],
            function: Castro._mproxy_removeSilences
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "getLatestEpisode",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Episode.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_getLatestEpisode
        )
        SwiftGodot._registerMethod(
            className: className,
            name: "queue",
            flags: .default,
            returnValue: SwiftGodot._returnValuePropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast"),
                SwiftGodot._argumentPropInfo(Podcast.self, name: "preceedingPodcast")
            ],
            function: Castro._mproxy_queue
        )
    }()
}