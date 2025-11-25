//
//  WrappedTests.swift
//
//
//  Created by Mikhail Tishin on 18.11.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime

final class WrappedTests: GodotTestCase {
    
    override class var godotSubclasses: [Object.Type] {
        return [SubtypedNode.self]
    }

    /// Checks memory leaks of the swift wrappers during object's life cycle
    func testRetain () async throws {
        // queueFree deletes the node at the end of the current frame,
        // so we need the scene to wait for processFrame signal
        let scene = try GodotRuntime.getScene ()
        let checker = ReferenceChecker ()
        
        // framework object
        autoreleasepool {
            let node = Node ()
            checker.reference = node
            node.queueFree ()
        }
        await scene.processFrame.emitted
        checker.assertDisposed ()
        
        // subtyped object
        autoreleasepool {
            let node = SubtypedNode ()
            checker.reference = node
            node.queueFree ()
        }
        await scene.processFrame.emitted
        checker.assertDisposed ()
    }
    
    func testTopologicalSort() {
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
private class SubtypedNode: Node { }

final class ReferenceChecker {
    
    weak var reference: AnyObject?

    func assertDisposed (file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue (reference == nil, "Object was not disposed", file: file, line: line)
    }
    
}

@Godot
private class DuplicateClassTestNode: Node { }

final class DuplicateClassRegistrationTests: GodotTestCase {

    var duplicateClassNames: [StringName] = []

    func testDuplicateClassNameIsDetected() {
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
