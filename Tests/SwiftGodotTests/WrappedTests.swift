//
//  WrappedTests.swift
//
//
//  Created by Mikhail Tishin on 18.11.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class WrappedTests: GodotTestCase {
    
    override class var godotSubclasses: [Wrapped.Type] {
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
    
}

@Godot
private class SubtypedNode: Node { }

final class ReferenceChecker {
    
    weak var reference: AnyObject?
    
    func assertDisposed (file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue (reference == nil, "Object was not disposed", file: file, line: line)
    }
    
}
