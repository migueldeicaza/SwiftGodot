//
//  Vector2iTests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector2iTests {
    public func testOperatorUnaryMinus() {
        var value: Vector2i
        
        value = -Vector2i (x: -1, y: 2)
        assertEqual (value.x, 1)
        assertEqual (value.y, -2)
        
        value = -Vector2i (x: 3, y: -4)
        assertEqual (value.x, -3)
        assertEqual (value.y, 4)
        
        value = -Vector2i (x: Int32.max, y: Int32.max)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.min + 1)
        
        value = -Vector2i (x: Int32.min + 1, y: Int32.min + 1)
        assertEqual (value.x, Int32.max)
        assertEqual (value.y, Int32.max)
        
        value = -Vector2i (x: Int32.min, y: Int32.min)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, Int32.min)
    }

    public func testOperatorPlus() {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) + Vector2i (x: 3, y: 4)
        assertEqual (value.x, 4)
        assertEqual (value.y, 6)
        
        value = Vector2i (x: -5, y: 6) + Vector2i (x: 7, y: -8)
        assertEqual (value.x, 2)
        assertEqual (value.y, -2)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.min, y: Int32.max)
        assertEqual (value.x, -1)
        assertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.max, y: Int32.min) + Vector2i (x: Int32.max, y: Int32.min)
        assertEqual (value.x, -2)
        assertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.max, y: 1) + Vector2i (x: 1, y: 2)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, 3)
        
        value = Vector2i (x: 1, y: Int32.min) + Vector2i (x: 2, y: -1)
        assertEqual (value.x, 3)
        assertEqual (value.y, Int32.max)
    }

    public func testOperatorMinus() {
        var value: Vector2i
        
        value = Vector2i (x: 1, y: 2) - Vector2i (x: 3, y: 4)
        assertEqual (value.x, -2)
        assertEqual (value.y, -2)
        
        value = Vector2i (x: -5, y: 6) - Vector2i (x: 7, y: -8)
        assertEqual (value.x, -12)
        assertEqual (value.y, 14)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.min, y: Int32.max)
        assertEqual (value.x, 0)
        assertEqual (value.y, 0)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: Int32.max, y: Int32.min)
        assertEqual (value.x, 1)
        assertEqual (value.y, -1)
        
        value = Vector2i (x: Int32.min, y: Int32.max) - Vector2i (x: 2, y: -3)
        assertEqual (value.x, Int32.max - 1)
        assertEqual (value.y, Int32.min + 2)
        
        value = Vector2i (x: Int32.max - 1, y: Int32.min + 2) - Vector2i (x: -3, y: 4)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.max - 1)
    }
    
}
