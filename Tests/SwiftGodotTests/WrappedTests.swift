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
    
    override static func godotSetUp () {
        register (type: SubtypedNode.self)
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
            checker.assign (node)
            node.queueFree ()
            checker.free ()
        }
        await scene.processFrame.emitted
        checker.assertDisposed ()
        
        // subtyped object
        autoreleasepool {
            let node = SubtypedNode ()
            checker.assign (node)
            node.queueFree ()
            checker.free ()
        }
        await scene.processFrame.emitted
        checker.assertDisposed ()
    }
    
}

@Godot
class SubtypedNode: Node { }

final class ReferenceChecker {
    
    private var strongReference: AnyObject?
    private weak var weakReference: AnyObject?
    
    func assign (_ object: AnyObject) {
        strongReference = object
        weakReference = object
    }
    
    func free () {
        strongReference = nil
    }
    func assertDisposed (file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue (weakReference == nil, "Object was not disposed", file: file, line: line)
    }
    
}