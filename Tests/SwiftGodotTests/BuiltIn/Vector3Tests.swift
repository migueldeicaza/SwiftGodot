//
//  Vector3Tests.swift
//
//
//  Created by Mikhail Tishin on 21.10.2023.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class Vector3Tests: GodotTestCase {
    
    func testOperatorUnaryMinus () {
        var value: Vector3
        
        value = -Vector3 (x: -1.1, y: 2.2, z: -3.3)
        XCTAssertEqual (value.x, 1.1)
        XCTAssertEqual (value.y, -2.2)
        XCTAssertEqual (value.z, 3.3)
        
        value = -Vector3 (x: 4.4, y: -5.5, z: 6.6)
        XCTAssertEqual (value.x, -4.4)
        XCTAssertEqual (value.y, 5.5)
        XCTAssertEqual (value.z, -6.6)
        
        value = -Vector3 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude)
        XCTAssertEqual (value.x, .greatestFiniteMagnitude)
        XCTAssertEqual (value.y, -.greatestFiniteMagnitude)
        XCTAssertEqual (value.z, .greatestFiniteMagnitude)
        
        value = -Vector3 (x: .infinity, y: -.infinity, z: .infinity)
        XCTAssertEqual (value.x, -.infinity)
        XCTAssertEqual (value.y, .infinity)
        XCTAssertEqual (value.z, -.infinity)
        
        value = -Vector3 (x: .nan, y: .nan, z: .nan)
        XCTAssertTrue (value.x.isNaN)
        XCTAssertTrue (value.y.isNaN)
        XCTAssertTrue (value.z.isNaN)
    }
    
}
