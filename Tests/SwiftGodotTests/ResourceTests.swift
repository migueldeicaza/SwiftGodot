//
//  ResourceTests.swift
//  
//
//  Created by Patrick Beard on 12/3/23.
//

import XCTest
import SwiftGodotTestability
import SwiftGodot

final class ResourceTests: GodotTestCase {
    func testRefCountedLeaks() throws {
        let scene = PackedScene()
        let _ = scene.initRef()
        XCTAssertEqual(scene.getReferenceCount(), 1)
        let instanceID = Int64(bitPattern: UInt64(scene.getInstanceId()))
        XCTAssertTrue(GD.isInstanceIdValid(id: instanceID))
        let die = scene.unreference()
        XCTAssertTrue(die)
        XCTAssertTrue(GD.isInstanceIdValid(id: instanceID))
        XCTAssertEqual(scene.getReferenceCount(), 0)
    }
    
    func testRefCountedDeallocates() throws {
        let scene = PackedScene()
        let _ = scene.initRef()
        XCTAssertEqual(scene.getReferenceCount(), 1)
        let instanceID = Int64(bitPattern: UInt64(scene.getInstanceId()))
        XCTAssertTrue(GD.isInstanceIdValid(id: instanceID))
        scene.unref()
        XCTAssertFalse(GD.isInstanceIdValid(id: instanceID))
    }
}
