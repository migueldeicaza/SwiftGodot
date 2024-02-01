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

    func testHue () {
        XCTAssertEqual (Color.black.hue, 0)
        XCTAssertEqual (Color.white.hue, 0)
        
        XCTAssertEqual (Color.red.hue, 0.0 / 360.0)
        XCTAssertEqual (Color.green.hue, 120.0 / 360.0)
        XCTAssertEqual (Color.blue.hue, 240.0 / 360.0)
        XCTAssertEqual (Color.yellow.hue, 60.0 / 360.0)
        XCTAssertEqual (Color.cyan.hue, 180.0 / 360.0)
        XCTAssertEqual (Color.magenta.hue, 300.0 / 360.0)
        
        XCTAssertEqual (Color.hex (hex: 0x800000FF).hue, 0.0 / 360.0)
        XCTAssertEqual (Color.hex (hex: 0x008000FF).hue, 120.0 / 360.0)
        XCTAssertEqual (Color.hex (hex: 0x000080FF).hue, 240.0 / 360.0)
        XCTAssertEqual (Color.hex (hex: 0x808000FF).hue, 60.0 / 360.0)
        XCTAssertEqual (Color.hex (hex: 0x008080FF).hue, 180.0 / 360.0)
        XCTAssertEqual (Color.hex (hex: 0x800080FF).hue, 300.0 / 360.0)
    }
    
    func testSaturation () {
        XCTAssertEqual (Color.black.saturation, 0)
        XCTAssertEqual (Color.white.saturation, 0)
        
        XCTAssertEqual (Color.red.saturation, 1)
        XCTAssertEqual (Color.green.saturation, 1)
        XCTAssertEqual (Color.blue.saturation, 1)
        
        XCTAssertEqual (Color.hex (hex: 0x020204FF).saturation, 0.5)
        XCTAssertEqual (Color.hex (hex: 0x112222FF).saturation, 0.5)
        XCTAssertEqual (Color.hex (hex: 0xFEFE7FFF).saturation, 0.5)
    }
    
    func testValue () {
        XCTAssertEqual (Color.black.value, 0)
        XCTAssertEqual (Color.white.value, 1)
        
        XCTAssertEqual (Color.red.value, 1)
        XCTAssertEqual (Color.green.value, 1)
        XCTAssertEqual (Color.blue.value, 1)
        
        XCTAssertEqual (Color.hex (hex: 0x000033ff).value, 0.2)
        XCTAssertEqual (Color.hex (hex: 0x000066ff).value, 0.4)
        XCTAssertEqual (Color.hex (hex: 0x000099ff).value, 0.6)
        XCTAssertEqual (Color.hex (hex: 0x0000ccff).value, 0.8)
    }
    
}
