class Castro: Node {
    func deleteEpisode() {}

    func _mproxy_deleteEpisode(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        return SwiftGodot._macroCallableToVariant(deleteEpisode())

    }
    func subscribe(podcast: Podcast) {}

    func _mproxy_subscribe(arguments: borrowing SwiftGodot.Arguments) -> SwiftGodot.Variant? {
        do { // safe arguments access scope
            let arg0: Podcast = try arguments.argument(ofType: Podcast.self, at: 0)
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
            let arg0: Podcast? = try arguments.argument(ofType: Podcast?.self, at: 0)
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
            let arg0: Variant = try arguments.argument(ofType: Variant.self, at: 0)
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
            let arg0: Podcast = try arguments.argument(ofType: Podcast.self, at: 0)
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
            let arg0: Podcast = try arguments.argument(ofType: Podcast.self, at: 0)
            let arg1: Podcast = try arguments.argument(ofType: Podcast.self, at: 1)
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
        classInfo.registerMethod(name: StringName("deleteEpisode"), flags: .default, returnValue: nil, arguments: [], function: Castro._mproxy_deleteEpisode)
        let prop_0 = PropInfo (propertyType: .object, propertyName: "podcast", className: StringName("Podcast"), hint: .none, hintStr: "", usage: .default)
        let subscribeArgs = [
            prop_0,
        ]
        classInfo.registerMethod(name: StringName("subscribe"), flags: .default, returnValue: nil, arguments: subscribeArgs, function: Castro._mproxy_subscribe)
        let perhapsSubscribeArgs = [
            prop_0,
        ]
        classInfo.registerMethod(name: StringName("perhapsSubscribe"), flags: .default, returnValue: nil, arguments: perhapsSubscribeArgs, function: Castro._mproxy_perhapsSubscribe)
        let prop_1 = PropInfo (propertyType: .nil, propertyName: "from", className: StringName(""), hint: .none, hintStr: "", usage: .default)
        let removeSilencesArgs = [
            prop_1,
        ]
        classInfo.registerMethod(name: StringName("removeSilences"), flags: .default, returnValue: nil, arguments: removeSilencesArgs, function: Castro._mproxy_removeSilences)
        let prop_2 = PropInfo (propertyType: .object, propertyName: "", className: StringName("Episode"), hint: .none, hintStr: "", usage: .default)
        let getLatestEpisodeArgs = [
            prop_0,
        ]
        classInfo.registerMethod(name: StringName("getLatestEpisode"), flags: .default, returnValue: prop_2, arguments: getLatestEpisodeArgs, function: Castro._mproxy_getLatestEpisode)
        let prop_3 = PropInfo (propertyType: .object, propertyName: "preceedingPodcast", className: StringName("Podcast"), hint: .none, hintStr: "", usage: .default)
        let queueArgs = [
            prop_0,
            prop_3,
        ]
        classInfo.registerMethod(name: StringName("queue"), flags: .default, returnValue: nil, arguments: queueArgs, function: Castro._mproxy_queue)
    } ()
}