//
//  Vector4Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector4Tests: GodotTestCase {
    
    func testOperatorUnaryMinus () {
        var value: Vector4
        
        value = -Vector4 (x: -1.1, y: 2.2, z: -3.3, w: 4.4)
        XCTAssertEqual (value.x, 1.1)
        XCTAssertEqual (value.y, -2.2)
        XCTAssertEqual (value.z, 3.3)
        XCTAssertEqual (value.w, -4.4)
        
        value = -Vector4 (x: 5.5, y: -6.6, z: 7.7, w: -8.8)
        XCTAssertEqual (value.x, -5.5)
        XCTAssertEqual (value.y, 6.6)
        XCTAssertEqual (value.z, -7.7)
        XCTAssertEqual (value.w, 8.8)
        
        value = -Vector4 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude, w: .greatestFiniteMagnitude)
        XCTAssertEqual (value.x, .greatestFiniteMagnitude)
        XCTAssertEqual (value.y, -.greatestFiniteMagnitude)
        XCTAssertEqual (value.z, .greatestFiniteMagnitude)
        XCTAssertEqual (value.w, -.greatestFiniteMagnitude)
        
        value = -Vector4 (x: .infinity, y: -.infinity, z: .infinity, w: -.infinity)
        XCTAssertEqual (value.x, -.infinity)
        XCTAssertEqual (value.y, .infinity)
        XCTAssertEqual (value.z, -.infinity)
        XCTAssertEqual (value.w, .infinity)
        
        value = -Vector4 (x: .nan, y: .nan, z: .nan, w: .nan)
        XCTAssertTrue (value.x.isNaN)
        XCTAssertTrue (value.y.isNaN)
        XCTAssertTrue (value.z.isNaN)
        XCTAssertTrue (value.w.isNaN)
    }
    
}
