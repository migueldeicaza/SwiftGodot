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

    @SwiftGodotTest
    public func testDuplicateReturnedResourceKeepsSingleNativeReference() {
        let original = StyleBoxFlat()
        guard let duplicate = original.duplicate() as? StyleBoxFlat else {
            XCTFail("duplicate() should return a StyleBoxFlat")
            return
        }

        XCTAssertEqual(duplicate.getReferenceCount(), 1, "duplicate() should surface a single owned native reference")
    }

    @SwiftGodotTest
    public func testEngineReturnedFileAccessKeepsSingleNativeReference() {
        let testPath = "user://swiftgodot-engine-returned-refcount.txt"

        guard let writer = FileAccess.open(path: testPath, flags: .write) else {
            XCTFail("Expected to open a writable FileAccess")
            return
        }
        XCTAssertEqual(writer.getReferenceCount(), 1, "FileAccess.open() should not add an extra native reference")
        _ = writer.storeString("ok")
        writer.close()

        guard let reader = FileAccess.open(path: testPath, flags: .read) else {
            XCTFail("Expected to open a readable FileAccess")
            return
        }
        XCTAssertEqual(reader.getReferenceCount(), 1, "Reopened FileAccess should also surface a single native reference")
        reader.close()
    }

}
