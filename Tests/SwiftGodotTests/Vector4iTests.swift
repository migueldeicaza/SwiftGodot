//
//  Vector4iTests.swift
//  
//
//  Created by Mikhail Tishin on 22.10.2023.
//

import XCTest
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
    }
    
}
