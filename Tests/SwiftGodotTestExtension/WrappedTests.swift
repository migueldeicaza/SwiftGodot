//
//  WrappedTests.swift
//
//
//  Created by Mikhail Tishin on 18.11.2023.
//


@testable import SwiftGodot
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

@SwiftGodotTestSuite
final class WrappedTests {
    public static var registeredTypes: [Object.Type] {
        return [SubtypedNode.self]
    }

    // Note: testRetain was removed as it relied on the embedded GodotRuntime.getScene()
    // which is not available in the new external Godot test architecture.
    // This test needs to be reimplemented using the scene tree available in the running Godot instance.

    @SwiftGodotTest
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

@SwiftGodotTestSuite
final class DuplicateClassRegistrationTests {
    var duplicateClassNames: [StringName] = []

    @SwiftGodotTest
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
