//
//  Vector2iTests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
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
    }
    
    func testOperatorMinus () {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) - Vector2i (x: 3, y: 4)
        XCTAssertEqual (value.x, -2)
        XCTAssertEqual (value.y, -2)
        
        value = Vector2i (x: -5, y: 6) - Vector2i (x: 7, y: -8)
        XCTAssertEqual (value.x, -12)
        XCTAssertEqual (value.y, 14)
    }
    
}
