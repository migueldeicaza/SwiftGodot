//
//  PlaneTests.swift
//
//
//  Created by Mikhail Tishin on 23.01.2024.
//

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class PlaneTests: GodotTestCase {
    
    func testOperatorUnaryMinus () {
        var value: Plane
        
        value = -Plane (normal: Vector3 (x: -1.1, y: 2.2, z: -3.3), d: 4.4)
        XCTAssertEqual (value.normal.x, 1.1)
        XCTAssertEqual (value.normal.y, -2.2)
        XCTAssertEqual (value.normal.z, 3.3)
        XCTAssertEqual (value.d, -4.4)
        
        value = -Plane (normal: Vector3 (x: 5.5, y: -6.6, z: 7.7), d: -8.8)
        XCTAssertEqual (value.normal.x, -5.5)
        XCTAssertEqual (value.normal.y, 6.6)
        XCTAssertEqual (value.normal.z, -7.7)
        XCTAssertEqual (value.d, 8.8)
        
        value = -Plane (normal: Vector3 (x: -.greatestFiniteMagnitude, y: .greatestFiniteMagnitude, z: -.greatestFiniteMagnitude), d: .greatestFiniteMagnitude)
        XCTAssertEqual (value.normal.x, .greatestFiniteMagnitude)
        XCTAssertEqual (value.normal.y, -.greatestFiniteMagnitude)
        XCTAssertEqual (value.normal.z, .greatestFiniteMagnitude)
        XCTAssertEqual (value.d, -.greatestFiniteMagnitude)
        
        value = -Plane (normal: Vector3 (x: .infinity, y: -.infinity, z: .infinity), d: -.infinity)
        XCTAssertEqual (value.normal.x, -.infinity)
        XCTAssertEqual (value.normal.y, .infinity)
        XCTAssertEqual (value.normal.z, -.infinity)
        XCTAssertEqual (value.d, .infinity)
        
        value = -Plane (normal: Vector3 (x: .nan, y: .nan, z: .nan), d: .nan)
        XCTAssertTrue (value.normal.x.isNaN)
        XCTAssertTrue (value.normal.y.isNaN)
        XCTAssertTrue (value.normal.z.isNaN)
        XCTAssertTrue (value.d.isNaN)
    }
    
}
