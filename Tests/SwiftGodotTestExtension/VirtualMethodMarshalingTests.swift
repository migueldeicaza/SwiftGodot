//
//  VirtualMethodMarshalingTests.swift
//  SwiftGodotTestExtension
//
//  Covers the marshaling that the generator emits for virtual-method proxies.  Godot calls those
//  proxies through ptrcall: arguments are *borrowed* native storage rather than Swift values, and
//  the return slot is uninitialized memory that the engine takes ownership of.  Every test here
//  makes the engine perform a real call into a Swift override, so a marshaling mistake shows up
//  as a wrong value, an emptied object, or a crash - not merely as a compile-time difference.
//

import Foundation
@testable import SwiftGodot

// MARK: - Variant arguments and enum returns

/// `MultiplayerAPI.objectConfigurationAdd(object:configuration:)` dispatches straight into
/// `_objectConfigurationAdd`, giving us a virtual with an `Object` argument, a `Variant` argument
/// and an enum return - all reachable without a scene tree.
@Godot
private final class ConfigRecordingMultiplayer: MultiplayerAPIExtension {
    var callCount = 0
    var lastObject: Object?
    var lastConfiguration: Variant?
    var lastConfigurationWasNil = false
    /// Handed back through Godot's int64-wide enum return slot.
    var resultToReturn: GodotError = .ok

    override func _objectConfigurationAdd(object: Object?, configuration: Variant?) -> GodotError {
        callCount += 1
        lastObject = object
        lastConfiguration = configuration
        lastConfigurationWasNil = configuration == nil
        return resultToReturn
    }
}

// MARK: - Enum arguments and enum returns

/// `XRInterface.PlayAreaMode.custom` has the raw value 2147483647 while being the sixth case, so
/// it distinguishes an enum marshaled through its raw value from one marshaled through the bytes
/// of its in-memory representation (which is the case *index*, one byte wide).
@Godot
private final class PlayAreaRecordingInterface: XRInterfaceExtension {
    var lastSupportsQuery: XRInterface.PlayAreaMode?
    var lastSetMode: XRInterface.PlayAreaMode?
    var modeToReturn: XRInterface.PlayAreaMode = .unknown
    /// Returned as-is from `_getPlayArea`: the proxy has to hand Godot a value of its own, since
    /// the engine destroys whatever it finds in the return slot and this array stays ours.
    var playArea = PackedVector3Array()

    override func _supportsPlayAreaMode(_ mode: XRInterface.PlayAreaMode) -> Bool {
        lastSupportsQuery = mode
        return mode == .custom
    }

    override func _setPlayAreaMode(_ mode: XRInterface.PlayAreaMode) -> Bool {
        lastSetMode = mode
        return true
    }

    override func _getPlayAreaMode() -> XRInterface.PlayAreaMode {
        return modeToReturn
    }

    override func _getPlayArea() -> PackedVector3Array {
        return playArea
    }
}

// MARK: - Typed array arguments

/// `Logger._logError` takes a typed array of `ScriptBacktrace` objects. This target's reduced API
/// maps that unavailable engine class to its `RefCounted` fallback. `TypedArray` is a struct whose
/// only stored property is the `VariantArray` *class*, so loading one out of the ptrcall slot would
/// reinterpret Godot's own array storage as a Swift object reference and corrupt the heap on the
/// first retain or release.
@Godot
private final class RecordingLogger: Logger {
    var errorCount = 0
    /// `GD.pushError` reports its message through `code`, with an empty `rationale`.
    var lastMessage = ""
    /// Kept alive past the call to prove the array we were handed is a real Godot array and not a
    /// reinterpretation of borrowed storage.
    var lastBacktraces: TypedArray<RefCounted?>?
    var lastBacktraceCount = -1

    override func _logError(function: String, file: String, line: Int32, code: String, rationale: String, editorNotify: Bool, errorType: Int32, scriptBacktraces: TypedArray<RefCounted?>) {
        errorCount += 1
        lastMessage = rationale.isEmpty ? code : rationale
        lastBacktraceCount = scriptBacktraces.count
        lastBacktraces = scriptBacktraces
    }
}

// MARK: - Variant and typed array returns, and a second enum argument

/// `TextServer`'s public methods are instance methods that dispatch straight into these overrides,
/// so a plain `TextServerExtension` subclass suffices - no need to register a text server.
///
/// `InlineAlignment` is worth a second enum test next to `PlayAreaMode`: its raw values run
/// 1, 3, 2, 4, 8, 12, 0, 5, 14 against case indices 0...8, so almost every case tells apart an
/// enum marshaled through `rawValue` from one marshaled through its in-memory representation.
@Godot
private final class CachedTextServer: TextServerExtension {
    var spanMeta: Variant? = Variant(0)
    var sizeCacheList = TypedArray<Vector2i>()
    var lastInlineAlign: InlineAlignment?
    var lastObjectKey: Variant?

    override func _shapedGetSpanMeta(shaped: RID, index: Int) -> Variant? {
        return spanMeta
    }

    override func _fontGetSizeCacheList(fontRid: RID) -> TypedArray<Vector2i> {
        return sizeCacheList
    }

    override func _shapedTextAddObject(shaped: RID, key: Variant?, size: Vector2, inlineAlign: InlineAlignment, length: Int, baseline: Double) -> Bool {
        lastInlineAlign = inlineAlign
        lastObjectKey = key
        return true
    }
}

@SwiftGodotTestSuite
final class VirtualMethodMarshalingTests {
    public static var registeredTypes: [Object.Type] {
        return [
            ConfigRecordingMultiplayer.self,
            PlayAreaRecordingInterface.self,
            RecordingLogger.self,
            CachedTextServer.self,
        ]
    }

    // MARK: Variant arguments

    /// A `Variant` argument arrives as Godot's own 24-byte payload rather than as a Swift object
    /// reference, so the proxy has to copy it.  Round-trips one Variant of every storage flavour:
    /// inline (int), refcounted builtin (string, dictionary) and object.
    public func testVariantArgumentRoundTrip() {
        let multiplayer = ConfigRecordingMultiplayer()
        let node = Node()
        defer { node.queueFree() }

        _ = multiplayer.objectConfigurationAdd(object: node, configuration: Variant(42))
        assertEqual(multiplayer.callCount, 1)
        assertEqual(multiplayer.lastConfiguration?.gtype, .int)
        assertEqual(multiplayer.lastConfiguration.flatMap { Int($0) }, 42)

        _ = multiplayer.objectConfigurationAdd(object: node, configuration: Variant("hello"))
        assertEqual(multiplayer.lastConfiguration?.gtype, .string)
        assertEqual(multiplayer.lastConfiguration.flatMap { String($0) }, "hello")

        let dictionary = VariantDictionary()
        dictionary["key"] = Variant("value")
        _ = multiplayer.objectConfigurationAdd(object: node, configuration: Variant(dictionary))
        assertEqual(multiplayer.lastConfiguration?.gtype, .dictionary)
        let received = multiplayer.lastConfiguration.flatMap { VariantDictionary($0) }
        assertEqual(received?["key"].flatMap { String($0) }, "value")

        _ = multiplayer.objectConfigurationAdd(object: node, configuration: Variant(node))
        assertEqual(multiplayer.lastConfiguration?.gtype, .object)
        assertEqual(multiplayer.lastConfiguration.to(Node.self), node)

        assertEqual(multiplayer.lastObject, node)
        assertEqual(multiplayer.callCount, 4)
    }

    /// Godot clears only the *type tag* of a Nil Variant, leaving the rest of the payload as
    /// whatever the engine stack happened to hold, so nil-ness cannot be decided by comparing the
    /// whole payload against zero.
    public func testNilVariantArgumentArrivesAsNil() {
        let multiplayer = ConfigRecordingMultiplayer()
        let node = Node()
        defer { node.queueFree() }

        // Interleaved with non-nil calls: a stale payload left behind by the previous call is
        // exactly what makes a byte-wise nil check report a Nil Variant as non-nil.
        for _ in 0 ..< 8 {
            _ = multiplayer.objectConfigurationAdd(object: node, configuration: Variant("stale payload"))
            assertFalse(multiplayer.lastConfigurationWasNil)

            _ = multiplayer.objectConfigurationAdd(object: node, configuration: nil)
            assertTrue(multiplayer.lastConfigurationWasNil, "A Godot Nil Variant must arrive as nil")
            assertNil(multiplayer.lastConfiguration)
        }
    }

    /// A `nil` object argument must not be resolved into some other instance.
    public func testNilObjectArgumentArrivesAsNil() {
        let multiplayer = ConfigRecordingMultiplayer()

        _ = multiplayer.objectConfigurationAdd(object: nil, configuration: Variant(1))
        assertNil(multiplayer.lastObject)
    }

    // MARK: Enum returns

    /// Godot's return slot for an enum is an `int64_t`, and a Swift enum's memory layout is its
    /// case index rather than its raw value, so the raw value has to be written out at full width.
    public func testEnumReturnRoundTrip() {
        let multiplayer = ConfigRecordingMultiplayer()
        let node = Node()
        defer { node.queueFree() }

        for expected: GodotError in [.ok, .failed, .errUnavailable, .errBusy, .errPrinterOnFire] {
            multiplayer.resultToReturn = expected
            let actual = multiplayer.objectConfigurationAdd(object: node, configuration: Variant(0))
            assertEqual(actual, expected, "GodotError \(expected) (raw \(expected.rawValue)) did not survive the return slot")
        }
    }

    /// `PlayAreaMode.custom` is the sixth case but carries the raw value 2147483647, so it only
    /// survives a round trip if both directions go through `rawValue`.
    public func testWideEnumReturnRoundTrip() {
        let interface = PlayAreaRecordingInterface()

        for expected: XRInterface.PlayAreaMode in [.unknown, .sitting, .stage, .custom] {
            interface.modeToReturn = expected
            assertEqual(interface.xrPlayAreaMode, expected, "PlayAreaMode \(expected) (raw \(expected.rawValue)) did not survive the return slot")
        }
    }

    // MARK: Enum arguments

    /// The mirror of the test above: an enum argument arrives as an `int64_t` in the ptrcall slot
    /// and has to be rebuilt through `rawValue`.
    public func testEnumArgumentRoundTrip() {
        let interface = PlayAreaRecordingInterface()

        for mode: XRInterface.PlayAreaMode in [.unknown, .xrPlayArea3dof, .sitting, .roomscale, .stage, .custom] {
            let supported = interface.supportsPlayAreaMode(mode)
            assertEqual(interface.lastSupportsQuery, mode, "PlayAreaMode \(mode) (raw \(mode.rawValue)) did not survive the argument slot")
            assertEqual(supported, mode == .custom)

            interface.xrPlayAreaMode = mode
            assertEqual(interface.lastSetMode, mode)
        }
    }

    // MARK: Typed array arguments

    /// `_logError` receives a `TypedArray`, which wraps the `VariantArray` class: the proxy has to
    /// run Godot's copy constructor over the borrowed storage instead of loading a Swift value out
    /// of it.  Getting this wrong releases bytes Godot owns, so this test crashes rather than
    /// fails when the marshaling regresses.
    public func testTypedArrayArgument() {
        let logger = RecordingLogger()
        OS.addLogger(logger)
        defer { OS.removeLogger(logger) }

        for i in 0 ..< 16 {
            GD.pushError(arg1: Variant("marshaling probe \(i)"))
        }

        assertGreaterThanOrEqual(logger.errorCount, 16)
        assertTrue(logger.lastMessage.contains("marshaling probe 15"), "Got message: \(logger.lastMessage)")

        // The array outlived the call: reading it here would touch Godot's own storage if the
        // proxy had handed us a reinterpretation of the borrowed pointer.
        assertNotNil(logger.lastBacktraces)
        assertGreaterThanOrEqual(logger.lastBacktraceCount, 0)
        assertEqual(logger.lastBacktraces?.count, logger.lastBacktraceCount)
    }

    // MARK: Builtin returns

    /// Godot destroys the value left in the return slot, so a proxy that gives away the storage of
    /// the object the override returned empties a collection its owner still holds.
    public func testBuiltinReturnLeavesCallersStorageIntact() {
        let interface = PlayAreaRecordingInterface()
        let corners = [
            Vector3(x: 0, y: 0, z: 0),
            Vector3(x: 1, y: 0, z: 0),
            Vector3(x: 1, y: 0, z: 1),
        ]
        for corner in corners {
            interface.playArea.append(corner)
        }

        for round in 1 ... 5 {
            let area = interface.getPlayArea()
            assertEqual(area.size(), 3, "Round \(round): the engine got \(area.size()) corners")
            for (i, corner) in corners.enumerated() {
                assertEqual(area[i], corner, "Round \(round), corner \(i)")
            }
            assertEqual(interface.playArea.size(), 3, "Round \(round): the interface's own array was emptied by the return")
        }

        for (i, corner) in corners.enumerated() {
            assertEqual(interface.playArea[i], corner)
        }
    }

    // MARK: Variant returns

    /// Same ownership rule on the `Variant` return path: `_shapedGetSpanMeta` hands back a
    /// `Variant` the text server keeps in a stored property.
    public func testVariantReturnLeavesCallersStorageIntact() {
        let textServer = CachedTextServer()

        let meta = VariantDictionary()
        meta["kind"] = Variant("probe")
        textServer.spanMeta = Variant(meta)

        for round in 1 ... 5 {
            let returned = textServer.shapedGetSpanMeta(shaped: RID(), index: 0)
            assertEqual(returned?.gtype, .dictionary, "Round \(round): got \(String(describing: returned?.gtype))")
            let dictionary = returned.flatMap { VariantDictionary($0) }
            assertEqual(dictionary?["kind"].flatMap { String($0) }, "probe", "Round \(round)")

            // The text server's own Variant must still hold the dictionary.
            assertEqual(textServer.spanMeta?.gtype, .dictionary, "Round \(round): the stored Variant was emptied by the return")
        }

        assertEqual(meta["kind"].flatMap { String($0) }, "probe")
    }

    /// A Nil `Variant` return has to reach the caller as nil rather than as some leftover payload.
    public func testNilVariantReturn() {
        let textServer = CachedTextServer()

        textServer.spanMeta = Variant("not nil")
        assertNotNil(textServer.shapedGetSpanMeta(shaped: RID(), index: 0))

        textServer.spanMeta = nil
        assertNil(textServer.shapedGetSpanMeta(shaped: RID(), index: 0))
    }

    /// And on the typed array return path, which stores through `TypedArray`'s wrapped
    /// `VariantArray` rather than through a builtin's content directly.
    public func testTypedArrayReturnLeavesCallersStorageIntact() {
        let textServer = CachedTextServer()
        let sizes = [Vector2i(x: 12, y: 0), Vector2i(x: 16, y: 1)]
        for size in sizes {
            textServer.sizeCacheList.append(size)
        }

        for round in 1 ... 5 {
            let returned = textServer.fontGetSizeCacheList(fontRid: RID())
            assertEqual(returned.count, 2, "Round \(round): the engine got \(returned.count) entries")
            for (i, size) in sizes.enumerated() {
                assertEqual(returned[i], size, "Round \(round), entry \(i)")
            }
            assertEqual(textServer.sizeCacheList.count, 2, "Round \(round): the stored typed array was emptied by the return")
        }

        for (i, size) in sizes.enumerated() {
            assertEqual(textServer.sizeCacheList[i], size)
        }
    }

    /// `InlineAlignment`'s raw values are shuffled relative to its case indices, so it separates
    /// the two ways an enum argument can be decoded even more sharply than `PlayAreaMode` does.
    public func testShuffledEnumArgumentRoundTrip() {
        let textServer = CachedTextServer()

        for alignment in InlineAlignment.allCases {
            _ = textServer.shapedTextAddObject(shaped: RID(), key: Variant("key"), size: Vector2(x: 1, y: 1), inlineAlign: alignment)
            assertEqual(textServer.lastInlineAlign, alignment, "InlineAlignment \(alignment) (raw \(alignment.rawValue)) did not survive the argument slot")
            assertEqual(textServer.lastObjectKey.flatMap { String($0) }, "key")
        }
    }
}
