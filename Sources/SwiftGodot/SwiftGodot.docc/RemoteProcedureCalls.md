# Remote Procedure Calls

Use the `@Rpc` macro to configure methods for Godot's multiplayer RPC system.

## Overview

Remote Procedure Calls (RPC) allow you to call methods on other peers in a
multiplayer game. In Godot, RPC methods need to be configured with settings
that control who can call them and how they are transmitted over the network.

SwiftGodot provides the `@Rpc` macro to declaratively configure RPC methods,
similar to GDScript's `@rpc` annotation. The configuration is automatically
applied when your node enters the scene tree.

## Basic Usage

To mark a method for RPC, apply both the `@Callable` and `@Rpc` macros:

```swift
@Godot
class Player: Node {
    @Callable @Rpc
    func takeDamage(_ amount: Int) {
        health -= amount
    }
}
```

The `@Callable` macro exposes the method to Godot, and `@Rpc` configures it
for remote calls. With default settings, only the multiplayer authority
(typically the server) can call this method on other peers.

## RPC Parameters

The `@Rpc` macro accepts several parameters to customize the RPC behavior:

### mode

Controls who is allowed to call this RPC method. Uses ``MultiplayerAPI/RPCMode``:

- `.authority` (default): Only the multiplayer authority can call this method
- `.anyPeer`: Any connected peer can call this method

```swift
@Callable @Rpc(mode: .anyPeer)
func sendChatMessage(_ message: String) {
    displayMessage(message)
}
```

### callLocal

When `true`, the method is also called locally when you invoke the RPC.
Defaults to `false`.

```swift
@Callable @Rpc(mode: .authority, callLocal: true)
func startGame() {
    // Called on all peers AND locally when the authority calls rpc("start_game")
    initializeGame()
}
```

### transferMode

Controls how the RPC packets are sent over the network.
Uses ``MultiplayerPeer/TransferMode``:

- `.unreliable` (default): Packets may be lost or arrive out of order (fastest)
- `.unreliableOrdered`: Packets may be lost but arrive in order
- `.reliable`: Packets are guaranteed to arrive in order (slowest)

```swift
// Position updates can tolerate some packet loss
@Callable @Rpc(mode: .authority, transferMode: .unreliable)
func syncPosition(_ position: Vector3) {
    self.position = position
}

// Game state changes must be reliable
@Callable @Rpc(mode: .authority, transferMode: .reliable)
func playerDied(_ playerId: Int) {
    handlePlayerDeath(playerId)
}
```

### transferChannel

Specifies the network channel for the RPC. Defaults to `0`.
Different channels can be used to separate different types of traffic.

```swift
@Callable @Rpc(transferMode: .reliable, transferChannel: 1)
func importantGameEvent(_ eventId: Int) {
    processEvent(eventId)
}
```

## Complete Example

Here's a complete example showing various RPC configurations for a multiplayer game:

```swift
@Godot
class NetworkPlayer: CharacterBody3D {
    var health: Int = 100

    // Anyone can request to shoot, server validates
    @Callable @Rpc(mode: .anyPeer, transferMode: .reliable)
    func requestShoot(_ direction: Vector3) {
        // Server-side validation
        if multiplayer.isServer() {
            performShoot(direction)
        }
    }

    // Only server can sync position, unreliable is fine for frequent updates
    @Callable @Rpc(mode: .authority, transferMode: .unreliable)
    func syncPosition(_ pos: Vector3, _ rot: Vector3) {
        position = pos
        rotation = rot
    }

    // Only server can deal damage, must be reliable
    @Callable @Rpc(mode: .authority, transferMode: .reliable, callLocal: true)
    func takeDamage(_ amount: Int) {
        health -= amount
        if health <= 0 {
            die()
        }
    }

    // Chat messages from any peer, reliable delivery
    @Callable @Rpc(mode: .anyPeer, transferMode: .reliable)
    func sendChat(_ message: String) {
        displayChatMessage(message)
    }
}
```

## How It Works

When you use the `@Rpc` macro, the `@Godot` macro automatically generates
code that configures the RPC settings for your methods. This happens in
a special `_before_ready()` method that is called automatically before
your node's `_ready()` method.

The generated code calls ``Node/rpcConfig(method:config:)`` for each
`@Rpc`-marked method with a configuration dictionary containing:

- `rpc_mode`: The RPC mode value
- `call_local`: Whether to call locally
- `transfer_mode`: The transfer mode value
- `channel`: The transfer channel

You don't need to call anything manually - the RPC configuration is
applied automatically when your node enters the scene tree.

## Calling RPC Methods

Once configured, you can call RPC methods using Godot's standard RPC API:

```swift
// Call on all peers
rpc(StringName("sync_position"), Variant(newPosition))

// Call on a specific peer
rpcId(peerId, StringName("take_damage"), Variant(10))
```

Note that method names are converted to snake_case when exposed to Godot,
so `syncPosition` becomes `sync_position` in RPC calls.

## Requirements

- The `@Rpc` macro can only be applied to functions
- Methods must also have the `@Callable` macro to be exposed to Godot
- Your class must inherit from ``Node`` (directly or indirectly) since
  RPC is a Node feature
- Your class must use the `@Godot` macro

## See Also

- ``Node/rpc(_:_:)``
- ``Node/rpcId(_:method:_:)``
- ``Node/rpcConfig(method:config:)``
- ``MultiplayerAPI/RPCMode``
- ``MultiplayerPeer/TransferMode``
