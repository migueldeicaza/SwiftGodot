//
//  Vector2Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector2Tests: GodotTestCase {
    
    func testOperatorUnaryMinus () {
        var value: Vector2
        
        value = -Vector2 (x: -1.1, y: 2.2)
        XCTAssertEqual (value.x, 1.1)
        XCTAssertEqual (value.y, -2.2)
        
        value = -Vector2 (x: 3.3, y: -4.4)
        XCTAssertEqual (value.x, -3.3)
        XCTAssertEqual (value.y, 4.4)
        
        value = -Vector2 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude)
        XCTAssertEqual (value.x, .greatestFiniteMagnitude)
        XCTAssertEqual (value.y, -.greatestFiniteMagnitude)
        
        value = -Vector2 (x: .infinity, y: -.infinity)
        XCTAssertEqual (value.x, -.infinity)
        XCTAssertEqual (value.y, .infinity)
        
        value = -Vector2 (x: .nan, y: .nan)
        XCTAssertTrue (value.x.isNaN)
        XCTAssertTrue (value.y.isNaN)
    }
    
}
