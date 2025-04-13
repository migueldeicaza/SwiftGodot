class Castro: Node {
    func deleteEpisode() {}

    func _mproxy_deleteEpisode(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._wrapCallableResult(deleteEpisode())

    }
    func subscribe(podcast: Podcast) {}

    func _mproxy_subscribe(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._wrapCallableResult(subscribe(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `subscribe`: \(error.description)")
        }

        return nil
    }
    func perhapsSubscribe(podcast: Podcast?) {}

    func _mproxy_perhapsSubscribe(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast?.self, at: 0)
            return SwiftGodot._wrapCallableResult(perhapsSubscribe(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `perhapsSubscribe`: \(error.description)")
        }

        return nil
    }
    func removeSilences(from: Variant) {}

    func _mproxy_removeSilences(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Variant.self, at: 0)
            return SwiftGodot._wrapCallableResult(removeSilences(from: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `removeSilences`: \(error.description)")
        }

        return nil
    }
    func getLatestEpisode(podcast: Podcast) -> Episode {}

    func _mproxy_getLatestEpisode(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._wrapCallableResult(getLatestEpisode(podcast: arg0))

        } catch {
            SwiftGodot.GD.printErr("Error calling `getLatestEpisode`: \(error.description)")
        }

        return nil
    }
    func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}

    func _mproxy_queue(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            let arg1 = try arguments.argument(ofType: Podcast.self, at: 1)
            return SwiftGodot._wrapCallableResult(queue(arg0, after: arg1))

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
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Castro> (name: className)
        classInfo.registerMethod(
            name: "deleteEpisode",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [

            ],
            function: Castro._mproxy_deleteEpisode
        )
        classInfo.registerMethod(
            name: "subscribe",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_subscribe
        )
        classInfo.registerMethod(
            name: "perhapsSubscribe",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast?.self, name: "podcast")
            ],
            function: Castro._mproxy_perhapsSubscribe
        )
        classInfo.registerMethod(
            name: "removeSilences",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Variant.self, name: "from")
            ],
            function: Castro._mproxy_removeSilences
        )
        classInfo.registerMethod(
            name: "getLatestEpisode",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Episode.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast")
            ],
            function: Castro._mproxy_getLatestEpisode
        )
        classInfo.registerMethod(
            name: "queue",
            flags: .default,
            returnValue: SwiftGodot._returnedPropInfo(Swift.Void.self),
            arguments: [
                SwiftGodot._argumentPropInfo(Podcast.self, name: "podcast"),
                SwiftGodot._argumentPropInfo(Podcast.self, name: "preceedingPodcast")
            ],
            function: Castro._mproxy_queue
        )
    } ()
}