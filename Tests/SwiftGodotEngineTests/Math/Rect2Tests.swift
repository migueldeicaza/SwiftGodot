// Based on godot/tests/core/math/test_rect2.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Rect2Tests: GodotTestCase {
    
    func testConstructorMethods () {
        let rect = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        let rectVector = Rect2 (position: Vector2 (x: 0, y: 100), size: Vector2 (x: 1280, y: 720))
        let rectCopyRect = Rect2 (from: rect)
        let rectCopyRecti = Rect2 (from: Rect2i (x: 0, y: 100, width: 1280, height: 720))
        
        XCTAssertEqual (rect, rectVector, "Rect2s created with the same dimensions but by different methods should be equal.")
        XCTAssertEqual (rect, rectCopyRect, "Rect2s created with the same dimensions but by different methods should be equal.")
        XCTAssertEqual (rect, rectCopyRecti, "Rect2s created with the same dimensions but by different methods should be equal.")
    }
    
    func testStringConversion () {
        // Note: This also depends on the Vector2 string representation.
        XCTAssertEqual (Variant (Rect2 (x: 0, y: 100, width: 1280, height: 720)).description, "[P: (0, 100), S: (1280, 720)]", "The string representation should match the expected value.")
    }
    
    func testBasicGetters () {
        let rect: Rect2 = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        XCTAssertEqual (rect.position, Vector2 (x: 0, y: 100), "position getter should return the expected value.")
        XCTAssertEqual (rect.size, Vector2 (x: 1280, y: 720), "size getter should return the expected value.")
        XCTAssertEqual (rect.end, Vector2 (x: 1280, y: 820), "end getter should return the expected value.")
        XCTAssertEqual (rect.getCenter (), Vector2 (x: 640, y: 460), "getCenter() should return the expected value.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: 1281, height: 721).getCenter (), Vector2 (x: 640.5, y: 460.5), "getCenter() should return the expected value.")
    }
    
    func testBasicSetters () {
        var rect: Rect2 = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        rect.end = Vector2 (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2 (x: 0, y: 100, width: 4000, height: 3900), "Setting end should result in the expected Rect2.")
        
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        rect.position = Vector2 (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2 (x: 4000, y: 4000, width: 1280, height: 720), "Setting position should result in the expected Rect2.")

        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        rect.size = Vector2 (x: 4000, y: 4000)
        XCTAssertEqual (rect, Rect2 (x: 0, y: 100, width: 4000, height: 4000), "Setting size should result in the expected Rect2.")
    }
    
    func testAreaGetters () {
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: 1280, height: 720).getArea (), 921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: -1280, height: -720).getArea (), 921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: 1280, height: -720).getArea (), -921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: -1280, height: 720).getArea (), -921_600, "getArea() should return the expected value.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: 0, height: 720).getArea (), 0, "getArea() should return the expected value.")

        XCTAssertTrue (Rect2 (x: 0, y: 100, width: 1280, height: 720).hasArea (), "hasArea() should return the expected value on Rect2 with an area.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 0, height: 500).hasArea (), "hasArea() should return the expected value on Rect2 with no area.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 500, height: 0).hasArea (), "hasArea() should return the expected value on Rect2 with no area.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 0, height: 0).hasArea (), "hasArea() should return the expected value on Rect2 with no area.")
    }
    
    func testAbsoluteCoordinates () {
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: 1280, height: 720).abs (), Rect2 (x: 0, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2.")
        XCTAssertEqual (Rect2 (x: 0, y: -100, width: 1280, height: 720).abs (), Rect2 (x: 0, y: -100, width: 1280, height: 720), "abs() should return the expected Rect2.")
        XCTAssertEqual (Rect2 (x: 0, y: -100, width: -1280, height: -720).abs (), Rect2 (x: -1280, y: -820, width: 1280, height: 720), "abs() should return the expected Rect2.")
        XCTAssertEqual (Rect2 (x: 0, y: 100, width: -1280, height: 720).abs (), Rect2 (x: -1280, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2.")
    }

    func testIntersection () {
        var rect: Rect2
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2 (x: 0, y: 300, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (x: 0, y: 300, width: 100, height: 100), "intersection() with fully enclosed Rect2 should return the expected result.")
        // The resulting Rect2 is 100 pixels high because the first Rect2 is vertically offset by 100 pixels.
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2 (x: 1200, y: 700, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (x: 1200, y: 700, width: 80, height: 100), "intersection() with partially enclosed Rect2 should return the expected result.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2 (x: -4000, y: -4000, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (), "intersection() with non-enclosed Rect2 should return the expected result.")
    }

    func testEnclosing () {
        XCTAssertTrue (Rect2 (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2 (x: 0, y: 300, width: 100, height: 100)), "encloses() with fully contained Rect2 should return the expected result.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2 (x: 1200, y: 700, width: 100, height: 100)), "encloses() with partially contained Rect2 should return the expected result.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2 (x: -4000, y: -4000, width: 100, height: 100)), "encloses() with non-contained Rect2 should return the expected result.")
    }

    func testExpanding () {
        var rect: Rect2
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2 (x: 500, y: 600))
        XCTAssertEqual (rect, Rect2 (x: 0, y: 100, width: 1280, height: 720), "expand() with contained Vector2 should return the expected result.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2 (x: 0, y: 0))
        XCTAssertEqual (rect, Rect2 (x: 0, y: 0, width: 1280, height: 820), "expand() with non-contained Vector2 should return the expected result.")
    }

    func testGrowing () {
        var rect: Rect2
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).grow (amount: 100)
        XCTAssertEqual (rect, Rect2 (x: -100, y: 0, width: 1480, height: 920), "grow() with positive value should return the expected Rect2.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).grow (amount: -100)
        XCTAssertEqual (rect, Rect2 (x: 100, y: 200, width: 1080, height: 520), "grow() with negative value should return the expected Rect2.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).grow (amount: -4000)
        XCTAssertEqual (rect, Rect2 (x: 4000, y: 4100, width: -6720, height: -7280), "grow() with large negative value should return the expected Rect2.")

        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: 100, top: 200, right: 300, bottom: 400)
        XCTAssertEqual (rect, Rect2 (x: -100, y: -100, width: 1680, height: 1320), "growIndividual() with positive values should return the expected Rect2.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: -100, top: 200, right: 300, bottom: -400)
        XCTAssertEqual (rect, Rect2 (x: 100, y: -100, width: 1480, height: 520), "growIndividual() with positive and negative values should return the expected Rect2.")

        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: 500)
        XCTAssertEqual (rect, Rect2 (x: 0, y: -400, width: 1280, height: 1220), "growSide() with positive value should return the expected Rect2.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: -500)
        XCTAssertEqual (rect, Rect2 (x: 0, y: 600, width: 1280, height: 220), "growSide() with negative value should return the expected Rect2.")
    }

    func testHasPpoint () {
        var rect: Rect2 = Rect2 (x: 0, y: 100, width: 1280, height: 720)
        XCTAssertTrue (rect.hasPoint (Vector2 (x: 500, y: 600)), "hasPoint() with contained Vector2 should return the expected result.")
        XCTAssertTrue (!rect.hasPoint (Vector2 (x: 0, y: 0)), "hasPoint() with non-contained Vector2 should return the expected result.")

        XCTAssertTrue (rect.hasPoint (rect.position), "hasPoint() with positive size should include `position`.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2 (x: 1, y: 1)), "hasPoint() with positive size should include `position + (1, 1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2 (x: 1, y: -1)), "hasPoint() with positive size should not include `position + (1, -1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size), "hasPoint() with positive size should not include `position + size`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size + Vector2 (x: 1, y: 1)), "hasPoint() with positive size should not include `position + size + (1, 1)`.")
        XCTAssertTrue (rect.hasPoint (rect.position + rect.size + Vector2 (x: -1, y: -1)), "hasPoint() with positive size should include `position + size + (-1, -1)`.")
        XCTAssertTrue (!rect.hasPoint (rect.position + rect.size + Vector2 (x: -1, y: 1)), "hasPoint() with positive size should not include `position + size + (-1, 1)`.")

        XCTAssertTrue (rect.hasPoint (rect.position + Vector2 (x: 0, y: 10)), "hasPoint() with point located on left edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2 (x: rect.size.x, y: 10)), "hasPoint() with point located on right edge should return false.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2 (x: 10, y: 0)), "hasPoint() with point located on top edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2 (x: 10, y: rect.size.y)), "hasPoint() with point located on bottom edge should return false.")

        rect = Rect2 (x: -4000, y: -200, width: 1280, height: 720)
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2 (x: 0, y: 10)), "hasPoint() with negative position and point located on left edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2 (x: rect.size.x, y: 10)), "hasPoint() with negative position and point located on right edge should return false.")
        XCTAssertTrue (rect.hasPoint (rect.position + Vector2 (x: 10, y: 0)), "hasPoint() with negative position and point located on top edge should return true.")
        XCTAssertTrue (!rect.hasPoint (rect.position + Vector2 (x: 10, y: rect.size.y)), "hasPoint() with negative position and point located on bottom edge should return false.")
    }

    func testIntersects () {
        XCTAssertTrue (Rect2 (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2 (x: 0, y: 300, width: 100, height: 100)), "intersects() with fully enclosed Rect2 should return the expected result.")
        XCTAssertTrue (Rect2 (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2 (x: 1200, y: 700, width: 100, height: 100)), "intersects() with partially enclosed Rect2 should return the expected result.")
        XCTAssertTrue (!Rect2 (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2 (x: -4000, y: -4000, width: 100, height: 100)), "intersects() with non-enclosed Rect2 should return the expected result.")
    }

    func testMerging () {
        var rect: Rect2
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2 (x: 0, y: 300, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (x: 0, y: 100, width: 1280, height: 720), "merge() with fully enclosed Rect2 should return the expected result.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2 (x: 1200, y: 700, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (x: 0, y: 100, width: 1300, height: 720), "merge() with partially enclosed Rect2 should return the expected result.")
        rect = Rect2 (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2 (x: -4000, y: -4000, width: 100, height: 100))
        XCTAssertEqual (rect, Rect2 (x: -4000, y: -4000, width: 5280, height: 4820), "merge() with non-enclosed Rect2 should return the expected result.")
    }

    func testFiniteNumberChecks () {
        let x: Vector2 = Vector2 (x: 0, y: 1)
        let infinite: Vector2 = Vector2 (x: .nan, y: .nan)

        XCTAssertTrue (Rect2 (position: x, size: x).isFinite (), "Rect2 with all components finite should be finite")

        XCTAssertFalse (Rect2 (position: infinite, size: x).isFinite (), "Rect2 with one component infinite should not be finite.")
        XCTAssertFalse (Rect2 (position: x, size: infinite).isFinite (), "Rect2 with one component infinite should not be finite.")

        XCTAssertFalse (Rect2 (position: infinite, size: infinite).isFinite (), "Rect2 with two components infinite should not be finite.")
    }
    
}
