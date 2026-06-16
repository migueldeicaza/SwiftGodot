//
//  PlaneTests.swift
//
//
//  Created by Mikhail Tishin on 23.01.2024.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class PlaneTests {
    public func testOperatorUnaryMinus() {
        var value: Plane
        
        value = -Plane (normal: Vector3 (x: -1.1, y: 2.2, z: -3.3), d: 4.4)
        assertEqual (value.normal.x, 1.1)
        assertEqual (value.normal.y, -2.2)
        assertEqual (value.normal.z, 3.3)
        assertEqual (value.d, -4.4)
        
        value = -Plane (normal: Vector3 (x: 5.5, y: -6.6, z: 7.7), d: -8.8)
        assertEqual (value.normal.x, -5.5)
        assertEqual (value.normal.y, 6.6)
        assertEqual (value.normal.z, -7.7)
        assertEqual (value.d, 8.8)
        
        value = -Plane (normal: Vector3 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude), d: .greatestFiniteMagnitude)
        assertEqual (value.normal.x, .greatestFiniteMagnitude)
        assertEqual (value.normal.y, -.greatestFiniteMagnitude)
        assertEqual (value.normal.z, .greatestFiniteMagnitude)
        assertEqual (value.d, -.greatestFiniteMagnitude)
        
        value = -Plane (normal: Vector3 (x: .infinity, y: -.infinity, z: .infinity), d: -.infinity)
        assertEqual (value.normal.x, -.infinity)
        assertEqual (value.normal.y, .infinity)
        assertEqual (value.normal.z, -.infinity)
        assertEqual (value.d, .infinity)
        
        value = -Plane (normal: Vector3 (x: .nan, y: .nan, z: .nan), d: .nan)
        assertTrue (value.normal.x.isNaN)
        assertTrue (value.normal.y.isNaN)
        assertTrue (value.normal.z.isNaN)
        assertTrue (value.d.isNaN)
    }
    
}
