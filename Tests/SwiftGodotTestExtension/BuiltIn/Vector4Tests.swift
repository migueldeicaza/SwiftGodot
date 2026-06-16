//
//  Vector4Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector4Tests {
    public func testOperatorUnaryMinus() {
        var value: Vector4
        
        value = -Vector4 (x: -1.1, y: 2.2, z: -3.3, w: 4.4)
        assertEqual (value.x, 1.1)
        assertEqual (value.y, -2.2)
        assertEqual (value.z, 3.3)
        assertEqual (value.w, -4.4)
        
        value = -Vector4 (x: 5.5, y: -6.6, z: 7.7, w: -8.8)
        assertEqual (value.x, -5.5)
        assertEqual (value.y, 6.6)
        assertEqual (value.z, -7.7)
        assertEqual (value.w, 8.8)
        
        value = -Vector4 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude, w: .greatestFiniteMagnitude)
        assertEqual (value.x, .greatestFiniteMagnitude)
        assertEqual (value.y, -.greatestFiniteMagnitude)
        assertEqual (value.z, .greatestFiniteMagnitude)
        assertEqual (value.w, -.greatestFiniteMagnitude)
        
        value = -Vector4 (x: .infinity, y: -.infinity, z: .infinity, w: -.infinity)
        assertEqual (value.x, -.infinity)
        assertEqual (value.y, .infinity)
        assertEqual (value.z, -.infinity)
        assertEqual (value.w, .infinity)
        
        value = -Vector4 (x: .nan, y: .nan, z: .nan, w: .nan)
        assertTrue (value.x.isNaN)
        assertTrue (value.y.isNaN)
        assertTrue (value.z.isNaN)
        assertTrue (value.w.isNaN)
    }
    
}
