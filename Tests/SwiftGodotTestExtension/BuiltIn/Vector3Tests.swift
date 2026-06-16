//
//  Vector3Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector3Tests {
    public func testOperatorUnaryMinus() {
        var value: Vector3
        
        value = -Vector3 (x: -1.1, y: 2.2, z: -3.3)
        assertEqual (value.x, 1.1)
        assertEqual (value.y, -2.2)
        assertEqual (value.z, 3.3)
        
        value = -Vector3 (x: 4.4, y: -5.5, z: 6.6)
        assertEqual (value.x, -4.4)
        assertEqual (value.y, 5.5)
        assertEqual (value.z, -6.6)
        
        value = -Vector3 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude)
        assertEqual (value.x, .greatestFiniteMagnitude)
        assertEqual (value.y, -.greatestFiniteMagnitude)
        assertEqual (value.z, .greatestFiniteMagnitude)
        
        value = -Vector3 (x: .infinity, y: -.infinity, z: .infinity)
        assertEqual (value.x, -.infinity)
        assertEqual (value.y, .infinity)
        assertEqual (value.z, -.infinity)
        
        value = -Vector3 (x: .nan, y: .nan, z: .nan)
        assertTrue (value.x.isNaN)
        assertTrue (value.y.isNaN)
        assertTrue (value.z.isNaN)
    }        
}
