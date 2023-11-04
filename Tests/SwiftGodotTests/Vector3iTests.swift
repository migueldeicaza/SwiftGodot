//
//  Vector3iTests.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
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
    }
    
}
