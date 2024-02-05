import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class LinearInterpolationTests: GodotTestCase {
    
    func testDoubleLinearInterpolation() {
        let result = Double(1000).lerp(to: 1100, weight: 0.5)
        XCTAssertEqual(result, 1050)
        
        let result2 = Double(1000).lerp(to: 1100, weight: 0)
        XCTAssertEqual(result2, 1000)
        
        let result3 = Double(1000).lerp(to: 1100, weight: 1)
        XCTAssertEqual(result3, 1100)
    }
    
    func testFloatLinearInterpolation() {
        let result = Float(1000).lerp(to: 1100, weight: 0.5)
        XCTAssertEqual(result, 1050)
        
        let result2 = Float(1000).lerp(to: 1100, weight: 0)
        XCTAssertEqual(result2, 1000)
        
        let result3 = Float(1000).lerp(to: 1100, weight: 1)
        XCTAssertEqual(result3, 1100)
    }
    
    func testIntLinearInterpolation() {
        let result = Int(1000).lerp(to: 1100, weight: 0.5)
        XCTAssertEqual(result, 1050)
        
        let result2 = Int(1000).lerp(to: 1100, weight: 0)
        XCTAssertEqual(result2, 1000)
        
        let result3 = Int(1000).lerp(to: 1100, weight: 1)
        XCTAssertEqual(result3, 1100)
    }
    
    func testVector2LinearInterpolation() {
        let from = Vector2(x: 100, y: 100)
        let to = Vector2(x: 200, y: 200)
        
        let result = from.lerp(to: to, weight: 0.5)
        XCTAssertEqual(result, Vector2(x: 150, y: 150))
        
        let result2 = from.lerp(to: to, weight: 0)
        XCTAssertEqual(result2, from)
        
        let result3 = from.lerp(to: to, weight: 1)
        XCTAssertEqual(result3, to)
    }
    
    func testVector3LinearInterpolation() {
        let from = Vector3(x: 100, y: 100, z: 100)
        let to = Vector3(x: 200, y: 200, z: 200)
        
        let result = from.lerp(to: to, weight: 0.5)
        XCTAssertEqual(result, Vector3(x: 150, y: 150, z: 150))
        
        let result2 = from.lerp(to: to, weight: 0)
        XCTAssertEqual(result2, from)
        
        let result3 = from.lerp(to: to, weight: 1)
        XCTAssertEqual(result3, to)
    }
    
    func testVector4LinearInterpolation() {
        let from = Vector4(x: 100, y: 100, z: 100, w: 100)
        let to = Vector4(x: 200, y: 200, z: 200, w: 200)
        
        let result = from.lerp(to: to, weight: 0.5)
        XCTAssertEqual(result, Vector4(x: 150, y: 150, z: 150, w: 150))
        
        let result2 = from.lerp(to: to, weight: 0)
        XCTAssertEqual(result2, from)
        
        let result3 = from.lerp(to: to, weight: 1)
        XCTAssertEqual(result3, to)
    }
    
    func testColorLinearInterpolation() {
        let from = Color(r: 0.6, g: 0.6, b: 0.6, a: 0.6)
        let to = Color(r: 1, g: 1, b: 1, a: 1)
        
        let result = from.lerp(to: to, weight: 0.5)
        XCTAssertEqual(result, Color(r: 0.8, g: 0.8, b: 0.8, a: 0.8))
        
        let result2 = from.lerp(to: to, weight: 0)
        XCTAssertEqual(result2, from)
        
        let result3 = from.lerp(to: to, weight: 1)
        XCTAssertEqual(result3, to)
    }
    
    func testInverseInterpolation() {
        let from: Double = 1000
        let to: Double = 1100
        let weight = 0.5
        let result = from.lerp(to: to, weight: 0.5)
        XCTAssertEqual(result, 1050)
        let inverseResult = result.inverseLerp(from: from, to: to)
        XCTAssertEqual(weight, Double(inverseResult))
    }
}
