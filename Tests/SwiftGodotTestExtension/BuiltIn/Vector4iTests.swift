//
//  Vector4iTests.swift
//  
//
//  Created by Mikhail Tishin on 22.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector4iTests {
    public func testOperatorUnaryMinus() {
        var value: Vector4i
        
        value = -Vector4i (x: -1, y: 2, z: -3, w: 4)
        assertEqual (value.x, 1)
        assertEqual (value.y, -2)
        assertEqual (value.z, 3)
        assertEqual (value.w, -4)
        
        value = -Vector4i (x: 5, y: -6, z: 7, w: -8)
        assertEqual (value.x, -5)
        assertEqual (value.y, 6)
        assertEqual (value.z, -7)
        assertEqual (value.w, 8)
        
        value = -Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.min + 1)
        assertEqual (value.z, Int32.min + 1)
        assertEqual (value.w, Int32.min + 1)
        
        value = -Vector4i (x: Int32.min + 1, y: Int32.min + 1, z: Int32.min + 1, w: Int32.min + 1)
        assertEqual (value.x, Int32.max)
        assertEqual (value.y, Int32.max)
        assertEqual (value.z, Int32.max)
        assertEqual (value.w, Int32.max)
        
        value = -Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, Int32.min)
        assertEqual (value.z, Int32.min)
        assertEqual (value.w, Int32.min)
    }

    public func testOperatorPlus() {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) + Vector4i (x: 5, y: 6, z: 7, w: 8)
        assertEqual (value.x, 6)
        assertEqual (value.y, 8)
        assertEqual (value.z, 10)
        assertEqual (value.w, 12)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) + Vector4i (x: 13, y: -14, z: 15, w: -16)
        assertEqual (value.x, 4)
        assertEqual (value.y, -4)
        assertEqual (value.z, 4)
        assertEqual (value.w, -4)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        assertEqual (value.x, -2)
        assertEqual (value.y, -2)
        assertEqual (value.z, -2)
        assertEqual (value.w, -2)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        assertEqual (value.x, 0)
        assertEqual (value.y, 0)
        assertEqual (value.z, 0)
        assertEqual (value.w, 0)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) + Vector4i (x: 1, y: 2, z: 3, w: 4)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, Int32.min + 1)
        assertEqual (value.z, Int32.min + 2)
        assertEqual (value.w, Int32.min + 3)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) + Vector4i (x: -5, y: -6, z: -7, w: -8)
        assertEqual (value.x, Int32.max - 4)
        assertEqual (value.y, Int32.max - 5)
        assertEqual (value.z, Int32.max - 6)
        assertEqual (value.w, Int32.max - 7)
    }

    public func testOperatorMinus() {
        var value: Vector4i
        
        value = Vector4i (x: 1, y: 2, z: 3, w: 4) - Vector4i (x: 5, y: 6, z: 7, w: 8)
        assertEqual (value.x, -4)
        assertEqual (value.y, -4)
        assertEqual (value.z, -4)
        assertEqual (value.z, -4)
        
        value = Vector4i (x: -9, y: 10, z: -11, w: 12) - Vector4i (x: 13, y: -14, z: 15, w: -16)
        assertEqual (value.x, -22)
        assertEqual (value.y, 24)
        assertEqual (value.z, -26)
        assertEqual (value.w, 28)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min)
        assertEqual (value.x, -1)
        assertEqual (value.y, -1)
        assertEqual (value.z, -1)
        assertEqual (value.w, -1)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max)
        assertEqual (value.x, 1)
        assertEqual (value.y, 1)
        assertEqual (value.z, 1)
        assertEqual (value.w, 1)
        
        value = Vector4i (x: Int32.max, y: Int32.max, z: Int32.max, w: Int32.max) - Vector4i (x: -2, y: -3, z: -4, w: -5)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.min + 2)
        assertEqual (value.z, Int32.min + 3)
        assertEqual (value.w, Int32.min + 4)
        
        value = Vector4i (x: Int32.min, y: Int32.min, z: Int32.min, w: Int32.min) - Vector4i (x: 6, y: 7, z: 8, w: 9)
        assertEqual (value.x, Int32.max - 5)
        assertEqual (value.y, Int32.max - 6)
        assertEqual (value.z, Int32.max - 7)
        assertEqual (value.w, Int32.max - 8)
    }
    
}
