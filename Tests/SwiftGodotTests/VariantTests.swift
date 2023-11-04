//
//  VariantTests.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-31.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class VariantTests: GodotTestCase, Initializable {
    func testVariant() {
        let testString = "Hi"
        let variant = Variant(testString)
        let unwrapped = String(variant)
        
        XCTAssertEqual(unwrapped, testString)
    }
}
