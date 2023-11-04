//
//  Vector3iTests.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector3iTests: GodotTestCase {
    
    func testOperatorPlus () {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) + Vector3i (x: 4, y: 5, z: 6)
        XCTAssertEqual (value.x, 5)
        XCTAssertEqual (value.y, 7)
        XCTAssertEqual (value.z, 9)
        
        value = Vector3i (x: -7, y: 8, z: -9) + Vector3i (x: 10, y: -11, z: 12)
        XCTAssertEqual (value.x, 3)
        XCTAssertEqual (value.y, -3)
        XCTAssertEqual (value.z, 3)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        XCTAssertEqual (value.z, -2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        XCTAssertEqual (value.z, 0)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: 1, y: 2, z: 3)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, Int32.min + 1)
        XCTAssertEqual (value.z, Int32.min + 2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: -3, y: -2, z: -1)
        XCTAssertEqual (value.x, Int32.max - 2)
        XCTAssertEqual (value.y, Int32.max - 1)
        XCTAssertEqual (value.z, Int32.max)
    }
    
    func testOperatorMinus () {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) - Vector3i (x: 4, y: 5, z: 6)
        XCTAssertEqual (value.x, -3)
        XCTAssertEqual (value.y, -3)
        XCTAssertEqual (value.z, -3)
                
        value = Vector3i (x: -7, y: 8, z: -9) - Vector3i (x: 10, y: -11, z: 12)
        XCTAssertEqual (value.x, -17)
        XCTAssertEqual (value.y, 19)
        XCTAssertEqual (value.z, -21)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        XCTAssertEqual (value.z, -1)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, 1)
        XCTAssertEqual (value.z, 1)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: -2, y: -3, z: -4)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        XCTAssertEqual (value.z, Int32.min + 3)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: 5, y: 6, z: 7)
        XCTAssertEqual (value.x, Int32.max - 4)
        XCTAssertEqual (value.y, Int32.max - 5)
        XCTAssertEqual (value.z, Int32.max - 6)
    }
    
}
