# Host Godot in SwiftUI

SwiftGodotKit can show a Godot game in a SwiftUI view on macOS and iOS. The
SwiftUI host can call a method on a Godot node. A Godot signal can send a value
back to the host.

The [Axolotl sample](https://github.com/migueldeicaza/SwiftGodotKit/tree/main/Samples/AxolotlDemo)
shows this exchange in a working app. The host has a **Restart game** button and
a score label. The Godot scene has a `Main` node.

## Add the Godot view

Create one `GodotApp` for the app. Give the view the app through the SwiftUI
environment. Use `onReady` to get a `GodotAppViewHandle` after Godot starts:

```swift
import SwiftGodot
import SwiftGodotKit
import SwiftUI

@main
struct GameApp: App {
    @State private var app = GodotApp(packFile: "main.pck")

    var body: some Scene {
        WindowGroup {
            GameView(app: app)
        }
    }
}
```

By default, `GodotApp` looks for `main.pck` in the app resources. You can pass
`godotPackPath` to use another directory. The sample includes the pack file and
shows how to build it from the Godot project.

## Connect both directions

In GDScript, declare a signal and emit it when the score changes:

```gdscript
extends Node

signal score_changed(value: int)
var score := 0

func new_game() -> void:
    score = 0
    score_changed.emit(score)

func add_point() -> void:
    score += 1
    score_changed.emit(score)
```

In SwiftUI, find `Main` after the Godot view is ready. Connect a Swift
`Callable` to the signal. The signal callback moves the score update to the
main queue. Run the Godot method call through `runOnGodotThread`:

```swift
private struct GameView: View {
    let app: GodotApp
    @State private var game = GameState()

    var body: some View {
        VStack {
            Text("Score: \(game.score)")
            Button("Restart game") {
                game.restart(in: app)
            }
            .disabled(!game.isReady)

            GodotAppView(onReady: { handle in
                game.connect(to: handle)
            })
        }
        .environment(\.godotApp, app)
        .onDisappear {
            game.disconnect(in: app)
        }
    }
}

@Observable
private final class GameState {
    private(set) var score = 0
    private(set) var isReady = false
    @ObservationIgnored private var main: Node?
    @ObservationIgnored private var scoreConnection: Callable?

    func connect(to handle: GodotAppViewHandle) {
        guard main == nil,
              let scene = handle.getRoot()?.findChild(
                  pattern: "Main", recursive: true, owned: false
              )
        else { return }

        let connection = Callable { [weak self] (value: Int64) in
            DispatchQueue.main.async { [weak self] in
                self?.score = Int(value)
            }
        }
        guard scene.connect(signal: "score_changed", callable: connection) == .ok
        else { return }
        main = scene
        scoreConnection = connection
        isReady = true
    }

    func restart(in app: GodotApp) {
        app.runOnGodotThread { [weak self] in
            guard let main = self?.main else { return }
            _ = main.call(method: "new_game")
        }
    }

    func disconnect(in app: GodotApp) {
        isReady = false
        guard let main, let scoreConnection else { return }
        app.runOnGodotThread {
            main.disconnect(signal: "score_changed", callable: scoreConnection)
        }
        self.main = nil
        self.scoreConnection = nil
    }
}
```

Keep the `Callable` so that you can disconnect the signal when the SwiftUI view
goes away. For signals that SwiftGodot declares as typed properties, see
<doc:Signals>.
