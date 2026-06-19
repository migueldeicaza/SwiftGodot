//
//  NamingConventionTests.swift
//  SwiftGodotTestExtension
//
//  End-to-end tests for the `consistent_name_translation` trait: every Swift
//  identifier registered with Godot (methods, arguments, properties, getters/setters,
//  signals, RPC methods, enum constants, enum hint strings) must be exposed to the
//  engine in Godot's naming convention. These assert against the live ClassDB while
//  the package is built with its default traits (so the trait is enabled).
//

import SwiftGodot

// MARK: - Class under test

@Godot
class NamingConventionHost: Node {
    // camelCase method + camelCase argument
    @Callable func computeSpeedValue(targetNode: Object?) -> Int { 0 }

    // Acronym handling
    @Callable func makeHTTPRequest() {}

    // Single word — identity
    @Callable func run() {}

    // @Rpc method: registered via @Callable as `sync_world_state`, and the generated
    // `_before_ready` calls rpcConfig with the same converter, so the RPC config name
    // stays consistent with the registered method name.
    @Callable @Rpc func syncWorldState() {}

    // camelCase property -> snake_case property + get_/set_ accessors
    @Export var maxHealthPoints: Int = 0

    // camelCase signal
    @Signal var playerDidJump: SignalWithArguments<Int>

    // Nested enum: cases -> UPPER_SNAKE_CASE constants
    enum DamageKind: Int, CaseIterable {
        case fireDamage = 0
        case iceDamage = 1
    }

    // Exported enum property: drives the PROPERTY_HINT_ENUM hint string
    @Export var damageKind: DamageKind = .fireDamage
}

// MARK: - Helpers

private func methodArgumentNames(_ cls: StringName, _ method: StringName) -> [String] {
    for entry in ClassDB.classGetMethodList(class: cls, noInheritance: true) {
        guard let nameV = entry["name"], String(nameV) == String(method) else { continue }
        guard let argsV = entry["args"], let args = TypedArray<VariantDictionary>(argsV) else { return [] }
        return args.compactMap { arg in arg["name"].flatMap { String($0) } }
    }
    return []
}

private func enumPropertyHintString(_ host: Object, _ property: String) -> String? {
    for prop in host.getPropertyList() {
        guard let nameV = prop["name"], String(nameV) == property else { continue }
        return prop["hint_string"].flatMap { String($0) }
    }
    return nil
}

// MARK: - Tests

@SwiftGodotTestSuite
final class NamingConventionTests {
    public static var registeredTypes: [Object.Type] {
        [NamingConventionHost.self]
    }

    func testMethodNameConverted() {
        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "compute_speed_value", noInheritance: true),
            "method should be registered as compute_speed_value"
        )
        assertFalse(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "computeSpeedValue", noInheritance: true),
            "the verbatim Swift name should NOT be registered"
        )
        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "make_http_request", noInheritance: true),
            "acronym method should be registered as make_http_request"
        )
    }

    func testSingleWordMethodIsIdentity() {
        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "run", noInheritance: true),
            "single-word method should stay 'run'"
        )
    }

    func testArgumentNameConverted() {
        let args = methodArgumentNames("NamingConventionHost", "compute_speed_value")
        assertEqual(args, ["target_node"], "argument name should be converted to snake_case")
    }

    func testPropertyAndAccessorsConverted() {
        let host = NamingConventionHost()
        defer { host.queueFree() }

        let names = host.getPropertyList().compactMap { $0["name"].flatMap { String($0) } }
        assertTrue(names.contains("max_health_points"), "property should be registered as max_health_points")

        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "get_max_health_points", noInheritance: true),
            "getter should be get_max_health_points"
        )
        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "set_max_health_points", noInheritance: true),
            "setter should be set_max_health_points"
        )
    }

    func testSignalNameConverted() {
        assertTrue(
            ClassDB.classHasSignal(class: "NamingConventionHost", signal: "player_did_jump"),
            "signal should be registered as player_did_jump"
        )
        assertFalse(
            ClassDB.classHasSignal(class: "NamingConventionHost", signal: "playerDidJump"),
            "the verbatim Swift signal name should NOT be registered"
        )
    }

    func testRpcMethodNameConverted() {
        assertTrue(
            ClassDB.classHasMethod(class: "NamingConventionHost", method: "sync_world_state", noInheritance: true),
            "RPC method should be registered as sync_world_state"
        )
    }

    func testEnumCasesConvertedToUpperSnake() {
        assertEnumRegistered("NamingConventionHost", "DamageKind", cases: [
            "FIRE_DAMAGE": 0, "ICE_DAMAGE": 1,
        ])
    }

    func testExportedEnumHintStringConverted() {
        let host = NamingConventionHost()
        defer { host.queueFree() }

        guard let hint = enumPropertyHintString(host, "damage_kind") else {
            fail("Expected a hint_string for the damage_kind property")
            return
        }
        // Order follows the enum's case order.
        assertEqual(hint, "FIRE_DAMAGE:0,ICE_DAMAGE:1", "enum hint string should use Godot-convention constant names")
    }
}
