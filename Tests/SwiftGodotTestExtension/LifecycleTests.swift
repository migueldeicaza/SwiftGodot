//
//  LifecycleTests.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 8/8/24.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class LifecycleTests {
    /// Checks memory leaks of Resource objects, this tests the Resource codepath
    @SwiftGodotTest
    public func testFreeResource() {
        func createImageAndGetId () -> Int64 {
            let img = Image()
            let id = Int64(bitPattern: UInt64(img.getInstanceId()))
            XCTAssertTrue (GD.isInstanceIdValid(id: id), "Image was supposed to be alive")
            return id
        }
        let id = createImageAndGetId()
        releasePendingObjects()
        XCTAssertFalse (GD.isInstanceIdValid(id: id), "Expected image to be disposed")
    }

    /// Checks memory leaks of Resource objects, this tests the non-Resource, non-Node codepath
    @SwiftGodotTest
    public func testFreeObjects() {
        func createTimerAndGetId () -> Int64 {
            let img = UndoRedo()
            let id = Int64(bitPattern: UInt64(img.getInstanceId()))
            XCTAssertTrue (GD.isInstanceIdValid(id: id), "Timer was supposed to be alive")
            img.free()
            return id
        }
        let id = createTimerAndGetId()
        XCTAssertFalse (GD.isInstanceIdValid(id: id), "Expected timer to be disposed")
    }

}
