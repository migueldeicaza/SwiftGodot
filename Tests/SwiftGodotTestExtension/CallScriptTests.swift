//
//  CallScriptTests.swift
//  SwiftGodotTestExtension
//
//  Exercises `Wrapped.callScript` / `Wrapped.hasScript`, which invoke methods
//  defined by a GDScript attached to an object.
//

@testable import SwiftGodotRuntime
@testable import SwiftGodot

@SwiftGodotTestSuite
final class CallScriptTests {
    /// Builds a `RefCounted` instance with a GDScript attached that defines a
    /// few methods we can call back into from Swift.
    private func makeScriptedObject() -> RefCounted? {
        let script = GDScript()
        script.sourceCode = """
        extends RefCounted

        func add(a, b):
            return a + b

        func greet(name):
            return "Hello, " + name

        func no_args():
            return 42
        """

        let reloadResult = script.reload()
        guard reloadResult == .ok else {
            fail("GDScript.reload() failed with \(reloadResult)")
            return nil
        }

        let object = RefCounted()
        object.setScript(script.toVariant())
        return object
    }

    public func testCallScriptWithArguments() {
        guard let object = makeScriptedObject() else { return }

        do {
            let result = try object.callScript(method: "add", Variant(2), Variant(3))
            assertEqual(result?.to(Int.self), 5, "add(2, 3) should return 5")
        } catch {
            fail("callScript(add) threw unexpectedly: \(error)")
        }
    }

    public func testCallScriptWithStringArgument() {
        guard let object = makeScriptedObject() else { return }

        do {
            let result = try object.callScript(method: "greet", Variant("Joey"))
            assertEqual(result?.to(String.self), "Hello, Joey", "greet should concatenate the name")
        } catch {
            fail("callScript(greet) threw unexpectedly: \(error)")
        }
    }

    public func testCallScriptWithNoArguments() {
        guard let object = makeScriptedObject() else { return }

        do {
            let result = try object.callScript(method: "no_args")
            assertEqual(result?.to(Int.self), 42, "no_args should return 42")
        } catch {
            fail("callScript(no_args) threw unexpectedly: \(error)")
        }
    }

    public func testHasScriptMethod() {
        guard let object = makeScriptedObject() else { return }

        assertTrue(object.hasScript(method: "add"), "hasScript should find a defined method")
        assertFalse(object.hasScript(method: "does_not_exist"), "hasScript should not find an undefined method")
    }

    public func testCallScriptUnknownMethodThrows() {
        guard let object = makeScriptedObject() else { return }

        do {
            _ = try object.callScript(method: "does_not_exist")
            fail("callScript should throw when the method does not exist")
        } catch {
            // Expected: invoking a missing script method surfaces a call error.
        }
    }
}
