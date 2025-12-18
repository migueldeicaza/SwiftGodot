//
//  WrappedTests.swift
//
//
//  Created by Mikhail Tishin on 18.11.2023.
//

import SwiftGodotTestability
@testable import SwiftGodot
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

public final class WrappedTests: GodotTestCase {
    public override class var godotSubclasses: [Object.Type] {
        return [SubtypedNode.self]
    }

    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testTopologicalSort", method: testTopologicalSort),
        ]
    }

    public required init() {}

    // Note: testRetain was removed as it relied on the embedded GodotRuntime.getScene()
    // which is not available in the new external Godot test architecture.
    // This test needs to be reimplemented using the scene tree available in the running Godot instance.

    public func testTopologicalSort() {
        class A: Object {
        }

        class B: A {
        }

        class C: B {
        }

        class D: C {
        }

        class E: D {
        }

        let expected = [A.self, B.self, C.self, D.self, E.self].map {
            ObjectIdentifier($0)
        }

        let output = [C.self, E.self, D.self, A.self, B.self]
            .topologicallySorted()
            .map { ObjectIdentifier($0) }

        XCTAssertEqual(expected, output)
    }
}

@Godot
class SubtypedNode: Node { }

final class ReferenceChecker {
    weak var reference: AnyObject?

    func assertDisposed (file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue (reference == nil, "Object was not disposed", file: file, line: line)
    }
}

@Godot
class DuplicateClassTestNode: Node { }

public final class DuplicateClassRegistrationTests: GodotTestCase {
    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testDuplicateClassNameIsDetected", method: testDuplicateClassNameIsDetected),
        ]
    }

    public required init() {}

    var duplicateClassNames: [StringName] = []

    public func testDuplicateClassNameIsDetected() {
        register(type: DuplicateClassTestNode.self)
        defer { unregister(type: DuplicateClassTestNode.self) }

        let old = duplicateClassNameDetected
        defer { duplicateClassNameDetected = old }

        duplicateClassNameDetected = { [weak self] name, type in
            self?.duplicateClassNames.append(name)
        }

        register(type: DuplicateClassTestNode.self)

        XCTAssertEqual(duplicateClassNames, ["DuplicateClassTestNode"])
    }
}
