//
//  Vector3iTests.swift
//
//
//  Created by Mikhail Tishin on 22.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector3iTests {
    public func testOperatorUnaryMinus() {
        var value: Vector3i
        
        value = -Vector3i (x: -1, y: 2, z: -3)
        assertEqual (value.x, 1)
        assertEqual (value.y, -2)
        assertEqual (value.z, 3)
        
        value = -Vector3i (x: 4, y: -5, z: 6)
        assertEqual (value.x, -4)
        assertEqual (value.y, 5)
        assertEqual (value.z, -6)
        
        value = -Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.min + 1)
        assertEqual (value.z, Int32.min + 1)
        
        value = -Vector3i (x: Int32.min + 1, y: Int32.min + 1, z: Int32.min + 1)
        assertEqual (value.x, Int32.max)
        assertEqual (value.y, Int32.max)
        assertEqual (value.z, Int32.max)
        
        value = -Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, Int32.min)
        assertEqual (value.z, Int32.min)
    }

    public func testOperatorPlus() {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) + Vector3i (x: 4, y: 5, z: 6)
        assertEqual (value.x, 5)
        assertEqual (value.y, 7)
        assertEqual (value.z, 9)
        
        value = Vector3i (x: -7, y: 8, z: -9) + Vector3i (x: 10, y: -11, z: 12)
        assertEqual (value.x, 3)
        assertEqual (value.y, -3)
        assertEqual (value.z, 3)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        assertEqual (value.x, -2)
        assertEqual (value.y, -2)
        assertEqual (value.z, -2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        assertEqual (value.x, 0)
        assertEqual (value.y, 0)
        assertEqual (value.z, 0)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) + Vector3i (x: 1, y: 2, z: 3)
        assertEqual (value.x, Int32.min)
        assertEqual (value.y, Int32.min + 1)
        assertEqual (value.z, Int32.min + 2)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) + Vector3i (x: -3, y: -2, z: -1)
        assertEqual (value.x, Int32.max - 2)
        assertEqual (value.y, Int32.max - 1)
        assertEqual (value.z, Int32.max)
    }

    public func testOperatorMinus() {
        var value: Vector3i
        
        value = Vector3i (x: 1, y: 2, z: 3) - Vector3i (x: 4, y: 5, z: 6)
        assertEqual (value.x, -3)
        assertEqual (value.y, -3)
        assertEqual (value.z, -3)
                
        value = Vector3i (x: -7, y: 8, z: -9) - Vector3i (x: 10, y: -11, z: 12)
        assertEqual (value.x, -17)
        assertEqual (value.y, 19)
        assertEqual (value.z, -21)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: Int32.min, y: Int32.min, z: Int32.min)
        assertEqual (value.x, -1)
        assertEqual (value.y, -1)
        assertEqual (value.z, -1)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: Int32.max, y: Int32.max, z: Int32.max)
        assertEqual (value.x, 1)
        assertEqual (value.y, 1)
        assertEqual (value.z, 1)
        
        value = Vector3i (x: Int32.max, y: Int32.max, z: Int32.max) - Vector3i (x: -2, y: -3, z: -4)
        assertEqual (value.x, Int32.min + 1)
        assertEqual (value.y, Int32.min + 2)
        assertEqual (value.z, Int32.min + 3)
        
        value = Vector3i (x: Int32.min, y: Int32.min, z: Int32.min) - Vector3i (x: 5, y: 6, z: 7)
        assertEqual (value.x, Int32.max - 4)
        assertEqual (value.y, Int32.max - 5)
        assertEqual (value.z, Int32.max - 6)
    }
    
}
