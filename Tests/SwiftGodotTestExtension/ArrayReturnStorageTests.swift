//
//  ArrayReturnStorageTests.swift
//  SwiftGodotTestExtension
//
//  When a method's return type is `Vector<Variant>` (or `Vector<RID>`, `Vector<Plane>`), the JSON says they return a plain `Array`.
//  However, their prtcall encoder calls resize() on the Array's storage. Passing an Array with zero'd storage therefore causes a crash.
//  We have special handling to pass a real Array to such methods to avoid the crash, and these tests make sure it's working.
//

import SwiftGodot

@SwiftGodotTestSuite
final class ArrayReturnStorageTests {
    /// `Animation.method_track_get_params` returns `Vector<Variant>`.
    public func testMethodTrackGetParamsReturnsTheKeyArguments() {
        let animation = Animation()
        let track = animation.addTrack(type: .method)
        let key = VariantDictionary()
        key["method"] = Variant(StringName("play"))
        let args = VariantArray()
        args.append(Variant("footstep"))
        args.append(Variant(3))
        key["args"] = Variant(args)
        _ = animation.trackInsertKey(trackIdx: track, time: 0, key: Variant(key))

        let params = animation.methodTrackGetParams(trackIdx: track, keyIdx: 0)
        assertEqual(params.count, 2)
        assertEqual(String(params[0]), "footstep")
        assertEqual(Int(params[1]), 3)
    }

    /// An empty `Vector<Variant>` still has to come back as a valid, empty array.
    public func testMethodTrackGetParamsWithNoArguments() {
        let animation = Animation()
        let track = animation.addTrack(type: .method)
        let key = VariantDictionary()
        key["method"] = Variant(StringName("play"))
        key["args"] = Variant(VariantArray())
        _ = animation.trackInsertKey(trackIdx: track, time: 0, key: Variant(key))

        let params = animation.methodTrackGetParams(trackIdx: track, keyIdx: 0)
        assertEqual(params.count, 0)
        params.append(Variant(1))
        assertEqual(params.count, 1, "the returned array is usable")
    }

    /// A method that really returns `Array` uses assignment to its storage rather than resize(). It still works with the
    /// constructed storage (and doesn't leak the empty array it replaces).
    public func testAssigningArrayReturnStillWorks() {
        let shortcut = Shortcut()
        let events = VariantArray()
        events.append(Variant(InputEventKey()))
        events.append(Variant(InputEventMouseButton()))
        shortcut.events = events

        let returned = shortcut.events
        assertEqual(returned.count, 2)
        assertTrue(returned[0]?.asObject(InputEventKey.self) != nil)
    }
}
