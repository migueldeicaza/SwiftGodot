//
//  Vector4iTests.swift
//  
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector4iTests: GodotTestCase {
    
    func testOperatorPlus () {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) + Vector4i (x: 5, y: 6, z: 7, w: 8)
        XCTAssertEqual (value.x, 6)
        XCTAssertEqual (value.y, 8)
        XCTAssertEqual (value.z, 10)
        XCTAssertEqual (value.w, 12)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) + Vector4i (x: 13, y: -14, z: 15, w: -16)
        XCTAssertEqual (value.x, 4)
        XCTAssertEqual (value.y, -4)
        XCTAssertEqual (value.z, 4)
        XCTAssertEqual (value.w, -4)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, -2)
        XCTAssertEqual (value.w, -2)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        XCTAssertEqual (value.z, 0)
        XCTAssertEqual (value.w, 0)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: 1, y: 2, z: 3, w: 4)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 2)
        XCTAssertEqual (value.w, Int32.min + 3)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: -5, y: -6, z: -7, w: -8)
        XCTAssertEqual (value.x, Int32.max - 4)
        XCTAssertEqual (value.y, Int32.max - 5)
        XCTAssertEqual (value.z, Int32.max - 6)
        XCTAssertEqual (value.w, Int32.max - 7)
    }
    
    func testOperatorMinus () {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) - Vector4i (x: 5, y: 6, z: 7, w: 8)
        XCTAssertEqual (value.x, -4)
        XCTAssertEqual (value.y, -4)
        XCTAssertEqual (value.z, -4)
        XCTAssertEqual (value.z, -4)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) - Vector4i (x: 13, y: -14, z: 15, w: -16)
        XCTAssertEqual (value.x, -22)
        XCTAssertEqual (value.y, 24)
        XCTAssertEqual (value.z, -26)
        XCTAssertEqual (value.w, 28)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        XCTAssertEqual (value.z, -1)
        XCTAssertEqual (value.w, -1)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, 1)
        XCTAssertEqual (value.z, 1)
        XCTAssertEqual (value.w, 1)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: -2, y: -3, z: -4, w: -5)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        XCTAssertEqual (value.z, Int32.min + 3)
        XCTAssertEqual (value.w, Int32.min + 4)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: 6, y: 7, z: 8, w: 9)
        XCTAssertEqual (value.x, Int32.max - 5)
        XCTAssertEqual (value.y, Int32.max - 6)
        XCTAssertEqual (value.z, Int32.max - 7)
        XCTAssertEqual (value.w, Int32.max - 8)
    }
    
}
