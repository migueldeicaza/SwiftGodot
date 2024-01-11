// Based on godot/tests/core/math/test_rect2i.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Rect2iTests: GodotTestCase {
    
    func testConstructorMethods () {
        let recti: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        let rectiVector: Rect2i = Rect2i (position: Vector2i (x: 0, y: 100), size: Vector2i (x: 1280, y: 720))
        let rectiCopyRecti: Rect2i = Rect2i (from: recti)
        let rectiCopyRect: Rect2i = Rect2i (from: Rect2 (x: 0, y: 100, width: 1280, height: 720))
        
        XCTAssertEqual (recti, rectiVector, "Rect2is created with the same dimensions but by different methods should be equal.")
        XCTAssertEqual (recti, rectiCopyRecti, "Rect2is created with the same dimensions but by different methods should be equal.")
        XCTAssertEqual (recti, rectiCopyRect, "Rect2is created with the same dimensions but by different methods should be equal.")
    }

    func testStringConversion () {
        // Note: This also depends on the Vector2 string representation.
        XCTAssertEqual (Variant (Rect2i (x: 0, y: 100, width: 1280, height: 720)).description, "[P: (0, 100), S: (1280, 720)]", "The string representation should match the expected value.")
    }

    func testBasicGetters () {
        let rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        XCTAssertEqual (rect.position, Vector2i (x: 0, y: 100), "position getter should return the expected value.")
        XCTAssertEqual (rect.size, Vector2i (x: 1280, y: 720), "size getter should return the expected value.")
        XCTAssertEqual (rect.end, Vector2i (x: 1280, y: 820), "end getter should return the expected value.")
        XCTAssertEqual (rect.getCenter (), Vector2i (x: 640, y: 460), "getCenter() should return the expected value.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1281, height: 721).getCenter (), Vector2i (x: 640, y: 460), "getCenter() should return the expected value.")
    }
    
    func testBasicSetters () {
        var rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.end = Vector2i (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2i (x: 0, y: 100, width: 4000, height: 3900), "Setting end should result in the expected Rect2i.")
        
        rect = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.position = Vector2i (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2i (x: 4000, y: 4000, width: 1280, height: 720), "Setting position should result in the expected Rect2i.")
        
        rect = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.size = Vector2i (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2i (x: 0, y: 100, width: 4000, height: 4000), "Setting size should result in the expected Rect2i.")
    }

    func testAreaGetters () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).getArea (), 921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: -1280, height: -720).getArea (), 921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: -720).getArea (), -921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: -1280, height: 720).getArea (), -921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 0, height: 720).getArea (), 0, "getArea() should return the expected value.")
        
        XCTAssertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).hasArea (), "hasArea() should return the expected value on Rect2i with an area.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 0, height: 500).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 500, height: 0).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 0, height: 0).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
    }
    
    func testAbsoluteCoordinates () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).abs (), Rect2i (x: 0, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: -100, width: 1280, height: 720).abs (), Rect2i (x: 0, y: -100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: -100, width: -1280, height: -720).abs (), Rect2i (x: -1280, y: -820, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: -1280, height: 720).abs (), Rect2i (x: -1280, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
    }

    func testIntersection () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), Rect2i (x: 0, y: 300, width: 100, height: 100), "intersection() with fully enclosed Rect2i should return the expected result.")
        // The resulting Rect2i is 100 pixels high because the first Rect2i is vertically offset by 100 pixels.
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), Rect2i (x: 1200, y: 700, width: 80, height: 100), "intersection() with partially enclosed Rect2i should return the expected result.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), Rect2i (), "intersection() with non-enclosed Rect2i should return the expected result.")
    }

    func testEnclosing () {
        XCTAssertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), "encloses() with fully contained Rect2i should return the expected result.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), "encloses() with partially contained Rect2i should return the expected result.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), "encloses() with non-contained Rect2i should return the expected result.")
        XCTAssertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 0, y: 100, width: 1280, height: 720)), "encloses() with identical Rect2i should return the expected result.")
    }

    func testExpanding () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2i (x: 500, y: 600)), Rect2i (x: 0, y: 100, width: 1280, height: 720), "expand() with contained Vector2i should return the expected result.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2i (x: 0, y: 0)), Rect2i (x: 0, y: 0, width: 1280, height: 820), "expand() with non-contained Vector2i should return the expected result.")
    }

    func testGrowing () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: 100), Rect2i (x: -100, y: 0, width: 1480, height: 920), "grow() with positive value should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: -100), Rect2i (x: 100, y: 200, width: 1080, height: 520), "grow() with negative value should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: -4000), Rect2i (x: 4000, y: 4100, width: -6720, height: -7280), "grow() with large negative value should return the expected Rect2i.")
        
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: 100, top: 200, right: 300, bottom: 400), Rect2i (x: -100, y: -100, width: 1680, height: 1320), "growIndividual() with positive values should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: -100, top: 200, right: 300, bottom: -400), Rect2i (x: 100, y: -100, width: 1480, height: 520), "growIndividual() with positive and negative values should return the expected Rect2i.")
        
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: 500), Rect2i (x: 0, y: -400, width: 1280, height: 1220), "growSide() with positive value should return the expected Rect2i.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: -500), Rect2i (x: 0, y: 600, width: 1280, height: 220), "growSide() with negative value should return the expected Rect2i.")
    }
    
    func testHasPoint () {
        var rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        XCTAssertTrue (rect.hasPoint (Vector2i (x: 500, y: 600)), "hasPoint() with contained Vector2i should return the expected result.")
        XCTAssertTrue (!rect.hasPoint (Vector2i (x: 0, y: 0)), "hasPoint() with non-contained Vector2i should return the expected result.")
        
        XCTAssertTrue (rect.hasPoint (rect.position), "hasPoint() with positive size should include `position`.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2i (x: 1, y: 1)), "hasPoint() with positive size should include `position + (1, 1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2i (x: 1, y: -1)), "hasPoint() with positive size should not include `position + (1, -1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size), "hasPoint() with positive size should not include `position + size`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size + Vector2i (x: 1, y: 1)), "hasPoint() with positive size should not include `position + size + (1, 1)`.")
        XCTAssertTrue (rect.hasPoint (rect.position + rect.size + Vector2i (x: -1, y: -1)), "hasPoint() with positive size should include `position + size + (-1, -1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size + Vector2i (x: -1, y: 1)), "hasPoint() with positive size should not include `position + size + (-1, 1)`.")
        
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2i (x: 0, y: 10)), "hasPoint() with point located on left edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2i (x: rect.size.x, y: 10)), "hasPoint() with point located on right edge should return false.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2i (x: 10, y: 0)), "hasPoint() with point located on top edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2i (x: 10, y: rect.size.y)), "hasPoint() with point located on bottom edge should return false.")
        
        rect = Rect2i (x: -4000, y: -200, width: 1280, height: 720)
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2i (x: 0, y: 10)), "hasPoint() with negative position and point located on left edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2i (x: rect.size.x, y: 10)), "hasPoint() with negative position and point located on right edge should return false.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2i (x: 10, y: 0)), "hasPoint() with negative position and point located on top edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2i (x: 10, y: rect.size.y)), "hasPoint() with negative position and point located on bottom edge should return false.")
    }

    func testIntersects () {
        XCTAssertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), "intersects() with fully enclosed Rect2i should return the expected result.")
        XCTAssertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), "intersects() with partially enclosed Rect2i should return the expected result.")
        XCTAssertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), "intersects() with non-enclosed Rect2i should return the expected result.")
        XCTAssertTrue (!Rect2i (x: 0, y: 0, width: 2, height: 2).intersects (b: Rect2i (x: 2, y: 2, width: 2, height: 2)), "intersects() with adjacent Rect2i should return the expected result.")
    }

    func testMerging () {
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), Rect2i (x: 0, y: 100, width: 1280, height: 720), "merge() with fully enclosed Rect2i should return the expected result.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), Rect2i (x: 0, y: 100, width: 1300, height: 720), "merge() with partially enclosed Rect2i should return the expected result.")
        XCTAssertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), Rect2i (x: -4000, y: -4000, width: 5280, height: 4820), "merge() with non-enclosed Rect2i should return the expected result.")
    }
    
}
