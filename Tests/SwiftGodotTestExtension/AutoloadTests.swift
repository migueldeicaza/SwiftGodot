import SwiftGodot

@Godot
class AutoloadTestState: Node {
    @Export var score: Int = 0
    @Export var readyCount: Int = 0
    @Export var processCount: Int = 0

    override func _ready() {
        readyCount += 1
    }

    override func _process(delta: Double) {
        processCount += 1
    }
}

@Godot
class AutoloadTestObserver: Node {
    @Export var sawStateReady: Bool = false

    override func _ready() {
        sawStateReady = AutoloadTestState.autoload(named: "SwiftTestState")?.readyCount == 1
    }
}

@SwiftGodotTestSuite
final class AutoloadTests {
    func testAutoloadIsReadyAndTyped() {
        guard let state = AutoloadTestState.autoload(named: "SwiftTestState") else {
            fail("Godot must create the Swift autoload before the main scene")
            return
        }
        assertEqual(state.readyCount, 1)
        assertEqual(state.name, "SwiftTestState")
        assertTrue(state.getParent() === (Engine.getMainLoop() as? SceneTree)?.root)
        state.score = 42
        assertEqual(AutoloadTestState.autoload(named: "SwiftTestState")?.score, 42)
    }

    func testAutoloadOrder() {
        let observer = AutoloadTestObserver.autoload(named: "SwiftTestObserver")
        assertNotNil(observer)
        assertTrue(observer?.sawStateReady == true)
    }

    func testMissingOrWrongTypeReturnsNil() {
        assertNil(AutoloadTestState.autoload(named: "MissingSwiftAutoload"))
        assertNil(AutoloadTestObserver.autoload(named: "SwiftTestState"))
        assertNil(AutoloadTestState.autoload(named: "../SwiftTestState"))
    }

    func testRegistrationRemovesDuplicateTypes() {
        let entries: [Autoload] = [
            .init(name: "First", type: AutoloadTestState.self),
            .init(name: "Second", type: AutoloadTestState.self)
        ]
        let types = entries.typesForRegistration(adding: [AutoloadTestState.self])
        assertEqual(types.count, 1)
        assertTrue(types.first == AutoloadTestState.self)
    }
}
