//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/20/24.
//

import Foundation
import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class PackedArrayTests: GodotTestCase {
    func testCustomInitializers () {
        let bytes: [UInt8] = [10, 20, 30, 255, 0, 3]
        
        let a = PackedByteArray (bytes)
        for (idx, v) in bytes.enumerated () {
            XCTAssertEqual (v, a [idx])
        }
        
        let ints: [Int32] = [10, 1024, 0xf00dca7, 0, 23, Int32.max, Int32.min]
        let b = PackedInt32Array (ints)
        for (idx, v) in ints.enumerated () {
            XCTAssertEqual (v, b [idx])
        }

        let longs: [Int64] = [10, 1024, 0xf00dca7dead, 0, Int64.max, Int64.min]
        let c = PackedInt64Array (longs)
        for (idx, v) in longs.enumerated () {
            XCTAssertEqual (v, c [idx])
        }

        let floats: [Float] = [0, 0.3, .pi, 0.3, 1000000.3]
        let d = PackedFloat32Array(floats)
        for (idx, v) in floats.enumerated() {
            XCTAssertEqual (v, d [idx])
        }

        let doubles: [Double] = [0, 0.3, .pi, 0.3, 1000000.3]
        let e = PackedFloat64Array(doubles)
        for (idx, v) in doubles.enumerated() {
            XCTAssertEqual (v, e [idx])
        }
    }
    
    func testPackedByteArrayExtract () {
        let bytes: [UInt8] = [10, 20, 30, 255, 0, 3]
        let packed = PackedByteArray(bytes)
        let ret = packed.asBytes()
        XCTAssertEqual (ret, bytes)
    }
}
