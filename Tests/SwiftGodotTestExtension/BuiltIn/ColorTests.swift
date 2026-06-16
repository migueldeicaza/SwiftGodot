//
//  ColorTests.swift
//
//
//  Created by Mikhail Tishin on 23.01.2024.
//



@testable import SwiftGodot

@SwiftGodotTestSuite
final class ColorTests {
    public func testOperatorUnaryMinus() {
        var value: Color
        
        value = -Color.white
        assertEqual (value.red, 0)
        assertEqual (value.green, 0)
        assertEqual (value.blue, 0)
        assertEqual (value.alpha, 0)
        
        value = -Color.black
        assertEqual (value.red, 1)
        assertEqual (value.green, 1)
        assertEqual (value.blue, 1)
        assertEqual (value.alpha, 0)
        
        value = -Color (r: 0.1, g: 0.2, b: 0.3, a: 0.4)
        assertEqual (value.red, 0.9)
        assertEqual (value.green, 0.8)
        assertEqual (value.blue, 0.7)
        assertEqual (value.alpha, 0.6)
    }

    public func testHue() {
        assertEqual (Color.black.hue, 0)
        assertEqual (Color.white.hue, 0)
        
        assertEqual (Color.red.hue, 0.0 / 360.0)
        assertEqual (Color.green.hue, 120.0 / 360.0)
        assertEqual (Color.blue.hue, 240.0 / 360.0)
        assertEqual (Color.yellow.hue, 60.0 / 360.0)
        assertEqual (Color.cyan.hue, 180.0 / 360.0)
        assertEqual (Color.magenta.hue, 300.0 / 360.0)
        
        assertEqual (Color.hex (hex: 0x800000FF).hue, 0.0 / 360.0)
        assertEqual (Color.hex (hex: 0x008000FF).hue, 120.0 / 360.0)
        assertEqual (Color.hex (hex: 0x000080FF).hue, 240.0 / 360.0)
        assertEqual (Color.hex (hex: 0x808000FF).hue, 60.0 / 360.0)
        assertEqual (Color.hex (hex: 0x008080FF).hue, 180.0 / 360.0)
        assertEqual (Color.hex (hex: 0x800080FF).hue, 300.0 / 360.0)
    }

    public func testSaturation() {
        assertEqual (Color.black.saturation, 0)
        assertEqual (Color.white.saturation, 0)
        
        assertEqual (Color.red.saturation, 1)
        assertEqual (Color.green.saturation, 1)
        assertEqual (Color.blue.saturation, 1)
        
        assertEqual (Color.hex (hex: 0x020204FF).saturation, 0.5)
        assertEqual (Color.hex (hex: 0x112222FF).saturation, 0.5)
        assertEqual (Color.hex (hex: 0xFEFE7FFF).saturation, 0.5)
    }

    public func testValue() {
        assertEqual (Color.black.value, 0)
        assertEqual (Color.white.value, 1)
        
        assertEqual (Color.red.value, 1)
        assertEqual (Color.green.value, 1)
        assertEqual (Color.blue.value, 1)
        
        assertEqual (Color.hex (hex: 0x000033ff).value, 0.2)
        assertEqual (Color.hex (hex: 0x000066ff).value, 0.4)
        assertEqual (Color.hex (hex: 0x000099ff).value, 0.6)
        assertEqual (Color.hex (hex: 0x0000ccff).value, 0.8)
    }
    
}
