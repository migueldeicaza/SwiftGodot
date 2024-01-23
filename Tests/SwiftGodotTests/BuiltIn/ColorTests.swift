//
//  ColorTests.swift
//
//
//  Created by Mikhail Tishin on 23.01.2024.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class ColorTests: GodotTestCase {
    
    func testOperatorUnaryMinus () {
        var value: Color
        
        value = -Color.white
        XCTAssertEqual (value.red, 0)
        XCTAssertEqual (value.green, 0)
        XCTAssertEqual (value.blue, 0)
        XCTAssertEqual (value.alpha, 0)
        
        value = -Color.black
        XCTAssertEqual (value.red, 1)
        XCTAssertEqual (value.green, 1)
        XCTAssertEqual (value.blue, 1)
        XCTAssertEqual (value.alpha, 0)
        
        value = -Color (r: 0.1, g: 0.2, b: 0.3, a: 0.4)
        XCTAssertEqual (value.red, 0.9)
        XCTAssertEqual (value.green, 0.8)
        XCTAssertEqual (value.blue, 0.7)
        XCTAssertEqual (value.alpha, 0.6)
    }
    
}
