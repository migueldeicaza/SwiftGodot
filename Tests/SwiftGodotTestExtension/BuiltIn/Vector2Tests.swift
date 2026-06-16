//
//  Vector2Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class Vector2Tests {
    public func testOperatorUnaryMinus() {
        var value: Vector2
        
        value = -Vector2 (x: -1.1, y: 2.2)
        assertEqual (value.x, 1.1)
        assertEqual (value.y, -2.2)
        
        value = -Vector2 (x: 3.3, y: -4.4)
        assertEqual (value.x, -3.3)
        assertEqual (value.y, 4.4)
        
        value = -Vector2 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude)
        assertEqual (value.x, .greatestFiniteMagnitude)
        assertEqual (value.y, -.greatestFiniteMagnitude)
        
        value = -Vector2 (x: .infinity, y: -.infinity)
        assertEqual (value.x, -.infinity)
        assertEqual (value.y, .infinity)
        
        value = -Vector2 (x: .nan, y: .nan)
        assertTrue (value.x.isNaN)
        assertTrue (value.y.isNaN)
    }
    
}
