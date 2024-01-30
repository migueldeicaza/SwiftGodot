// Based on godot/tests/core/math/test_color.h

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class ColorTests: GodotTestCase {
    
    func testConstructorMethods () {
        let blueRgba: Color = Color (r: 0.25098, g: 0.376471, b: 1, a: 0.501961)
        let blueHtml: Color = Color.html (rgba: "#4060ff80")
        let blueHex: Color = Color.hex (hex: 0x4060ff80)
        let blueHex64: Color = Color.hex64 (hex: 0x4040_6060_ffff_8080)
        
        XCTAssertTrue (blueRgba.isEqualApprox (to: blueHtml), "Creation with HTML notation should result in components approximately equal to the default constructor.")
        XCTAssertTrue (blueRgba.isEqualApprox (to: blueHex), "Creation with a 32-bit hexadecimal number should result in components approximately equal to the default constructor.")
        XCTAssertTrue (blueRgba.isEqualApprox (to: blueHex64), "Creation with a 64-bit hexadecimal number should result in components approximately equal to the default constructor.")
        
        let htmlInvalid: Color = Color.html (rgba: "invalid")
        
        XCTAssertTrue (htmlInvalid.isEqualApprox (to: Color ()), "Creation with invalid HTML notation should result in a Color with the default values.")
        
        let greenRgba: Color = Color (r: 0, g: 1, b: 0, a: 0.25)
        let greenHsva: Color = Color.fromHsv (h: 120 / 360.0, s: 1, v: 1, alpha: 0.25)
        
        XCTAssertTrue (greenRgba.isEqualApprox (to: greenHsva), "Creation with HSV notation should result in components approximately equal to the default constructor.")
    }

    func testOperators () {
        let blue: Color = Color (r: 0.2, g: 0.2, b: 1)
        let darkRed: Color = Color (r: 0.3, g: 0.1, b: 0.1)
        
        // Color components may be negative. Also, the alpha component may be greater than 1.0.
        assertApproxEqual (blue + darkRed, Color (r: 0.5, g: 0.3, b: 1.1, a: 2), "Color addition should behave as expected.")
        assertApproxEqual (blue - darkRed, Color (r: -0.1, g: 0.1, b: 0.9, a: 0), "Color subtraction should behave as expected.")
        assertApproxEqual (blue * 2, Color (r: 0.4, g: 0.4, b: 2, a: 2), "Color multiplication with a scalar should behave as expected.")
        assertApproxEqual (blue / 2, Color (r: 0.1, g: 0.1, b: 0.5, a: 0.5), "Color division with a scalar should behave as expected.")
        assertApproxEqual (blue * darkRed, Color (r: 0.06, g: 0.02, b: 0.1), "Color multiplication with another Color should behave as expected.")
        assertApproxEqual (blue / darkRed, Color (r: 0.666667, g: 2, b: 10), "Color division with another Color should behave as expected.")
        assertApproxEqual (-blue, Color (r: 0.8, g: 0.8, b: 0, a: 0), "Color negation should behave as expected (affecting the alpha channel, unlike `invert ()`).")
    }

    func testReadingMethods () {
        let darkBlue: Color = Color (r: 0, g: 0, b: 0.5, a: 0.4)
        XCTAssertEqual (darkBlue.hue, 240.0 / 360.0, "The returned HSV hue should match the expected value.")
        XCTAssertEqual (darkBlue.saturation, 1.0, "The returned HSV saturation should match the expected value.")
        XCTAssertEqual (darkBlue.value, 0.5, "The returned HSV value should match the expected value.")
    }


    func testConversionMethods () {
        let cyan: Color = Color (r: 0, g: 1, b: 1)
        let cyanTransparent: Color = Color (r: 0, g: 1, b: 1, a: 0)
        
        XCTAssertEqual (cyan.toHtml (), "00ffffff", "The returned RGB HTML color code should match the expected value.")
        XCTAssertEqual (cyanTransparent.toHtml (), "00ffff00", "The returned RGBA HTML color code should match the expected value.")
        XCTAssertEqual (cyan.toArgb32 (), 0xff00ffff, "The returned 32-bit RGB number should match the expected value.")
        XCTAssertEqual (cyan.toAbgr32 (), 0xffffff00, "The returned 32-bit BGR number should match the expected value.")
        XCTAssertEqual (cyan.toRgba32 (), 0x00ffffff, "The returned 32-bit BGR number should match the expected value.")
        XCTAssertEqual (cyan.toArgb64 (), Int64 (bitPattern: 0xffff_0000_ffff_ffff), "The returned 64-bit RGB number should match the expected value.")
        XCTAssertEqual (cyan.toAbgr64 (), Int64 (bitPattern: 0xffff_ffff_ffff_0000), "The returned 64-bit BGR number should match the expected value.")
        XCTAssertEqual (cyan.toRgba64 (), Int64 (bitPattern: 0x0000_ffff_ffff_ffff), "The returned 64-bit BGR number should match the expected value.")
        XCTAssertEqual (Variant (cyan).description, "(0, 1, 1, 1)", "The string representation should match the expected value.")
    }

    func testSrgbConversion () {
        let color: Color = Color (r: 0.35, g: 0.5, b: 0.6, a: 0.7)
        let colorLinear: Color = color.srgbToLinear ()
        let colorSrgb: Color = color.linearToSrgb ()
        XCTAssertTrue (colorLinear.isEqualApprox (to: Color (r: 0.100481, g: 0.214041, b: 0.318547, a: 0.7)), "The color converted to linear color space should match the expected value.")
        XCTAssertTrue (colorSrgb.isEqualApprox (to: Color (r: 0.62621, g: 0.735357, b: 0.797738, a: 0.7)), "The color converted to sRGB color space should match the expected value.")
        XCTAssertTrue (colorLinear.linearToSrgb ().isEqualApprox (to: Color (r: 0.35, g: 0.5, b: 0.6, a: 0.7)), "The linear color converted back to sRGB color space should match the expected value.")
        XCTAssertTrue (colorSrgb.srgbToLinear ().isEqualApprox (to: Color (r: 0.35, g: 0.5, b: 0.6, a: 0.7)), "The sRGB color converted back to linear color space should match the expected value.")
    }

    func testNamedColors () {
        XCTAssertEqual (Color (code: "red"), Color.hex (hex: 0xFF0000FF), "The named color \"red\" should match the expected value.")
        
        // Named colors have their names automatically normalized.
        XCTAssertEqual (Color (code: "whiteSmoke"), Color.hex (hex: 0xF5F5F5FF), "The named color \"whiteSmoke\" should match the expected value.")
        XCTAssertEqual (Color (code: "Slate Blue"), Color.hex (hex: 0x6A5ACDFF), "The named color \"Slate Blue\" should match the expected value.")
        
        XCTAssertTrue (Color (code: "doesn't exist").isEqualApprox (to: Color ()), "The invalid named color \"doesn't exist\" should result in a Color with the default values.")
    }

    func testValidationMethods () {
        XCTAssertTrue (Color.htmlIsValid (color: "#4080ff"), "Valid HTML color (with leading #) should be considered valid.")
        XCTAssertTrue (Color.htmlIsValid (color: "4080ff"), "Valid HTML color (without leading #) should be considered valid.")
        XCTAssertTrue (!Color.htmlIsValid (color: "12345"), "Invalid HTML color should be considered invalid.")
        XCTAssertTrue (!Color.htmlIsValid (color: "#fuf"), "Invalid HTML color should be considered invalid.")
    }

    func testManipulationMethods () {
        let blue: Color = Color (r: 0, g: 0, b: 1, a: 0.4)
        
        XCTAssertTrue (blue.inverted ().isEqualApprox (to: Color (r: 1, g: 1, b: 0, a: 0.4)), "Inverted color should have its red, green and blue components inverted.")
        
        let purple: Color = Color (r: 0.5, g: 0.2, b: 0.5, a: 0.25)
        
        XCTAssertTrue (purple.lightened (amount: 0.2).isEqualApprox (to: Color (r: 0.6, g: 0.36, b: 0.6, a: 0.25)), "Color should be lightened by the expected amount.")
        XCTAssertTrue (purple.darkened (amount: 0.2).isEqualApprox (to: Color (r: 0.4, g: 0.16, b: 0.4, a: 0.25)), "Color should be darkened by the expected amount.")
        
        let red: Color = Color (r: 1, g: 0, b: 0, a: 0.2)
        let yellow: Color = Color (r: 1, g: 1, b: 0, a: 0.8)
        
        XCTAssertTrue (red.lerp (to: yellow, weight: 0.5).isEqualApprox (to: Color (r: 1, g: 0.5, b: 0, a: 0.5)), "Red interpolated with yellow should be orange (with interpolated alpha).")
    }
    
}
