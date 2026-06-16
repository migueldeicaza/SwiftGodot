// Based on godot/tests/core/math/test_rect2i.h



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Rect2iTests {

    public func testConstructorMethods () {
        let recti: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        let rectiVector: Rect2i = Rect2i (position: Vector2i (x: 0, y: 100), size: Vector2i (x: 1280, y: 720))
        let rectiCopyRecti: Rect2i = Rect2i (from: recti)
        let rectiCopyRect: Rect2i = Rect2i (from: Rect2 (x: 0, y: 100, width: 1280, height: 720))
        
        assertEqual (recti, rectiVector, "Rect2is created with the same dimensions but by different methods should be equal.")
        assertEqual (recti, rectiCopyRecti, "Rect2is created with the same dimensions but by different methods should be equal.")
        assertEqual (recti, rectiCopyRect, "Rect2is created with the same dimensions but by different methods should be equal.")
    }

    public func testStringConversion () {
        // Note: This also depends on the Vector2 string representation.
        assertEqual (Variant (Rect2i (x: 0, y: 100, width: 1280, height: 720)).description, "[P: (0, 100), S: (1280, 720)]", "The string representation should match the expected value.")
    }

    public func testBasicGetters () {
        let rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        assertEqual (rect.position, Vector2i (x: 0, y: 100), "position getter should return the expected value.")
        assertEqual (rect.size, Vector2i (x: 1280, y: 720), "size getter should return the expected value.")
        assertEqual (rect.end, Vector2i (x: 1280, y: 820), "end getter should return the expected value.")
        assertEqual (rect.getCenter (), Vector2i (x: 640, y: 460), "getCenter() should return the expected value.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1281, height: 721).getCenter (), Vector2i (x: 640, y: 460), "getCenter() should return the expected value.")
    }
    
    public func testBasicSetters () {
        var rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.end = Vector2i (x: 4000, y: 4000)
        assertEqual (rect, Rect2i (x: 0, y: 100, width: 4000, height: 3900), "Setting end should result in the expected Rect2i.")
        
        rect = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.position = Vector2i (x: 4000, y: 4000)
        assertEqual (rect, Rect2i (x: 4000, y: 4000, width: 1280, height: 720), "Setting position should result in the expected Rect2i.")
        
        rect = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        rect.size = Vector2i (x: 4000, y: 4000)
        assertEqual (rect, Rect2i (x: 0, y: 100, width: 4000, height: 4000), "Setting size should result in the expected Rect2i.")
    }

    public func testAreaGetters () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).getArea (), 921_600, "getArea() should return the expected value.")
        assertEqual (Rect2i (x: 0, y: 100, width: -1280, height: -720).getArea (), 921_600, "getArea() should return the expected value.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: -720).getArea (), -921_600, "getArea() should return the expected value.")
        assertEqual (Rect2i (x: 0, y: 100, width: -1280, height: 720).getArea (), -921_600, "getArea() should return the expected value.")
        assertEqual (Rect2i (x: 0, y: 100, width: 0, height: 720).getArea (), 0, "getArea() should return the expected value.")
        
        assertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).hasArea (), "hasArea() should return the expected value on Rect2i with an area.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 0, height: 500).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 500, height: 0).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 0, height: 0).hasArea (), "hasArea() should return the expected value on Rect2i with no area.")
    }
    
    public func testAbsoluteCoordinates () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).abs (), Rect2i (x: 0, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: -100, width: 1280, height: 720).abs (), Rect2i (x: 0, y: -100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: -100, width: -1280, height: -720).abs (), Rect2i (x: -1280, y: -820, width: 1280, height: 720), "abs() should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: 100, width: -1280, height: 720).abs (), Rect2i (x: -1280, y: 100, width: 1280, height: 720), "abs() should return the expected Rect2i.")
    }

    public func testIntersection () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), Rect2i (x: 0, y: 300, width: 100, height: 100), "intersection() with fully enclosed Rect2i should return the expected result.")
        // The resulting Rect2i is 100 pixels high because the first Rect2i is vertically offset by 100 pixels.
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), Rect2i (x: 1200, y: 700, width: 80, height: 100), "intersection() with partially enclosed Rect2i should return the expected result.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersection (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), Rect2i (), "intersection() with non-enclosed Rect2i should return the expected result.")
    }

    public func testEnclosing () {
        assertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), "encloses() with fully contained Rect2i should return the expected result.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), "encloses() with partially contained Rect2i should return the expected result.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), "encloses() with non-contained Rect2i should return the expected result.")
        assertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).encloses (b: Rect2i (x: 0, y: 100, width: 1280, height: 720)), "encloses() with identical Rect2i should return the expected result.")
    }

    public func testExpanding () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2i (x: 500, y: 600)), Rect2i (x: 0, y: 100, width: 1280, height: 720), "expand() with contained Vector2i should return the expected result.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).expand (to: Vector2i (x: 0, y: 0)), Rect2i (x: 0, y: 0, width: 1280, height: 820), "expand() with non-contained Vector2i should return the expected result.")
    }

    public func testGrowing () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: 100), Rect2i (x: -100, y: 0, width: 1480, height: 920), "grow() with positive value should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: -100), Rect2i (x: 100, y: 200, width: 1080, height: 520), "grow() with negative value should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).grow (amount: -4000), Rect2i (x: 4000, y: 4100, width: -6720, height: -7280), "grow() with large negative value should return the expected Rect2i.")
        
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: 100, top: 200, right: 300, bottom: 400), Rect2i (x: -100, y: -100, width: 1680, height: 1320), "growIndividual() with positive values should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growIndividual (left: -100, top: 200, right: 300, bottom: -400), Rect2i (x: 100, y: -100, width: 1480, height: 520), "growIndividual() with positive and negative values should return the expected Rect2i.")
        
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: 500), Rect2i (x: 0, y: -400, width: 1280, height: 1220), "growSide() with positive value should return the expected Rect2i.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).growSide (Side.top.rawValue, amount: -500), Rect2i (x: 0, y: 600, width: 1280, height: 220), "growSide() with negative value should return the expected Rect2i.")
    }
    
    public func testHasPoint () {
        var rect: Rect2i = Rect2i (x: 0, y: 100, width: 1280, height: 720)
        assertTrue (rect.hasPoint (Vector2i (x: 500, y: 600)), "hasPoint() with contained Vector2i should return the expected result.")
        assertTrue (!rect.hasPoint (Vector2i (x: 0, y: 0)), "hasPoint() with non-contained Vector2i should return the expected result.")
        
        assertTrue (rect.hasPoint (rect.position), "hasPoint() with positive size should include `position`.")
        assertTrue (rect.hasPoint (rect.position + Vector2i (x: 1, y: 1)), "hasPoint() with positive size should include `position + (1, 1)`.")
        assertTrue (!rect.hasPoint (rect.position + Vector2i (x: 1, y: -1)), "hasPoint() with positive size should not include `position + (1, -1)`.")
        assertTrue (!rect.hasPoint (rect.position + rect.size), "hasPoint() with positive size should not include `position + size`.")
        assertTrue (!rect.hasPoint (rect.position + rect.size + Vector2i (x: 1, y: 1)), "hasPoint() with positive size should not include `position + size + (1, 1)`.")
        assertTrue (rect.hasPoint (rect.position + rect.size + Vector2i (x: -1, y: -1)), "hasPoint() with positive size should include `position + size + (-1, -1)`.")
        assertTrue (!rect.hasPoint (rect.position + rect.size + Vector2i (x: -1, y: 1)), "hasPoint() with positive size should not include `position + size + (-1, 1)`.")
        
        assertTrue (rect.hasPoint (rect.position + Vector2i (x: 0, y: 10)), "hasPoint() with point located on left edge should return true.")
        assertTrue (!rect.hasPoint (rect.position + Vector2i (x: rect.size.x, y: 10)), "hasPoint() with point located on right edge should return false.")
        assertTrue (rect.hasPoint (rect.position + Vector2i (x: 10, y: 0)), "hasPoint() with point located on top edge should return true.")
        assertTrue (!rect.hasPoint (rect.position + Vector2i (x: 10, y: rect.size.y)), "hasPoint() with point located on bottom edge should return false.")
        
        rect = Rect2i (x: -4000, y: -200, width: 1280, height: 720)
        assertTrue (rect.hasPoint (rect.position + Vector2i (x: 0, y: 10)), "hasPoint() with negative position and point located on left edge should return true.")
        assertTrue (!rect.hasPoint (rect.position + Vector2i (x: rect.size.x, y: 10)), "hasPoint() with negative position and point located on right edge should return false.")
        assertTrue (rect.hasPoint (rect.position + Vector2i (x: 10, y: 0)), "hasPoint() with negative position and point located on top edge should return true.")
        assertTrue (!rect.hasPoint (rect.position + Vector2i (x: 10, y: rect.size.y)), "hasPoint() with negative position and point located on bottom edge should return false.")
    }

    public func testIntersects () {
        assertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), "intersects() with fully enclosed Rect2i should return the expected result.")
        assertTrue (Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), "intersects() with partially enclosed Rect2i should return the expected result.")
        assertTrue (!Rect2i (x: 0, y: 100, width: 1280, height: 720).intersects (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), "intersects() with non-enclosed Rect2i should return the expected result.")
        assertTrue (!Rect2i (x: 0, y: 0, width: 2, height: 2).intersects (b: Rect2i (x: 2, y: 2, width: 2, height: 2)), "intersects() with adjacent Rect2i should return the expected result.")
    }

    public func testMerging () {
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: 0, y: 300, width: 100, height: 100)), Rect2i (x: 0, y: 100, width: 1280, height: 720), "merge() with fully enclosed Rect2i should return the expected result.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: 1200, y: 700, width: 100, height: 100)), Rect2i (x: 0, y: 100, width: 1300, height: 720), "merge() with partially enclosed Rect2i should return the expected result.")
        assertEqual (Rect2i (x: 0, y: 100, width: 1280, height: 720).merge (b: Rect2i (x: -4000, y: -4000, width: 100, height: 100)), Rect2i (x: -4000, y: -4000, width: 5280, height: 4820), "merge() with non-enclosed Rect2i should return the expected result.")
    }
    
}
