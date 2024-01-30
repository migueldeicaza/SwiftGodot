//
//  Vector2iTests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector2iTests: GodotTestCase {
    
    func testOperatorPlus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) + Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, 4)
        XCTAssertEqual (value.y, 6)
        
        value = Vector2i (x: -5, y: 6) + Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, 2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, -1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.max, y: 1) + Vector2i (x: 1, y: 2)
        XCTAssertEqual (value.x, Int32.min)
        XCTAssertEqual (value.y, 3)
        
        value = Vector2i (x: 1, y: Int32.min) + Vector2i (x: 2, y: -1)
        XCTAssertEqual (value.x, 3)
        XCTAssertEqual (value.y, Int32.max)
    }
    
    func testOperatorMinus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) - Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: -5, y: 6) - Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, -12)
        XCTAssertEqual (value.y, 14)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.min, y: Int32.max)
        XCTAssertEqual (value.x, 0)
        XCTAssertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.max, y: Int32.min)
        XCTAssertEqual (value.x, 1)
        XCTAssertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: 2, y: -3)
        XCTAssertEqual (value.x, Int32.max - 1)
        XCTAssertEqual (value.y, Int32.min + 2)
        
        value = Vector2i (x: Int32.max - 1, y: Int32.min + 2) - Vector2i (x: -3, y: 4)
        XCTAssertEqual (value.x, Int32.min + 1)
        XCTAssertEqual (value.y, Int32.max - 1)
    }
    
}
