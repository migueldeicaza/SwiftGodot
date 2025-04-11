class Castro: Node {
    func deleteEpisode() {}

    func _mproxy_deleteEpisode(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(deleteEpisode())

    }
    func subscribe(podcast: Podcast) {}

    func _mproxy_subscribe(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._macroCallableToVariant(subscribe(podcast: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `subscribe`: \(error)")
            return nil
        }
    }
    func perhapsSubscribe(podcast: Podcast?) {}

    func _mproxy_perhapsSubscribe(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast?.self, at: 0)
            return SwiftGodot._macroCallableToVariant(perhapsSubscribe(podcast: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `perhapsSubscribe`: \(error)")
            return nil
        }
    }
    func removeSilences(from: Variant) {}

    func _mproxy_removeSilences(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Variant.self, at: 0)
            return SwiftGodot._macroCallableToVariant(removeSilences(from: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `removeSilences`: \(error)")
            return nil
        }
    }
    func getLatestEpisode(podcast: Podcast) -> Episode {}

    func _mproxy_getLatestEpisode(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            return SwiftGodot._macroCallableToVariant(getLatestEpisode(podcast: arg0))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `getLatestEpisode`: \(error)")
            return nil
        }
    }
    func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}

    func _mproxy_queue(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0 = try arguments.argument(ofType: Podcast.self, at: 0)
            let arg1 = try arguments.argument(ofType: Podcast.self, at: 1)
            return SwiftGodot._macroCallableToVariant(queue(arg0, after: arg1))

        } catch let error as SwiftGodot.ArgumentAccessError {
            SwiftGodot.GD.printErr(error.description)
            return nil
        } catch {
            SwiftGodot.GD.printErr("Error calling `queue`: \(error)")
            return nil
        }
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
            name: StringName("deleteEpisode"),
            flags: .default,
            returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
            arguments: [],
            function: Castro._mproxy_deleteEpisode
        )
        classInfo.registerMethod(
                name: StringName("subscribe"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
                arguments: [_macroGodotGetCallablePropInfo(Podcast.self, name: "podcast")],
                function: Castro._mproxy_subscribe
            )
        classInfo.registerMethod(
                name: StringName("perhapsSubscribe"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
                arguments: [_macroGodotGetCallablePropInfo(Podcast?.self, name: "podcast")],
                function: Castro._mproxy_perhapsSubscribe
            )
        classInfo.registerMethod(
                name: StringName("removeSilences"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
                arguments: [_macroGodotGetCallablePropInfo(Variant.self, name: "from")],
                function: Castro._mproxy_removeSilences
            )
        classInfo.registerMethod(
                name: StringName("getLatestEpisode"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Episode.self),
                arguments: [_macroGodotGetCallablePropInfo(Podcast.self, name: "podcast")],
                function: Castro._mproxy_getLatestEpisode
            )
        classInfo.registerMethod(
                name: StringName("queue"),
                flags: .default,
                returnValue: _macroGodotGetCallablePropInfo(Swift.Void.self),
                arguments: [_macroGodotGetCallablePropInfo(Podcast.self, name: "podcast"), _macroGodotGetCallablePropInfo(Podcast.self, name: "preceedingPodcast")],
                function: Castro._mproxy_queue
            )
    } ()
}