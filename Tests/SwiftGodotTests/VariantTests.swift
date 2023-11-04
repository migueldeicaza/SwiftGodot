//
//  VariantTests.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-31.
//

import SwiftGodot
import XCTest

final class VariantTests: GodotTestCase {
    func testVariant() {
        let testString = "Hi"
        let variant = Variant(testString)
        let unwrapped = String(variant)
        
        XCTAssertEqual(unwrapped, testString)
    }
}
