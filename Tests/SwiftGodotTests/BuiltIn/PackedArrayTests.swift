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

        let vec2s: [Vector2] = [
            Vector2(),
            Vector2(x: 0.3, y: .pi),
            Vector2(x: .greatestFiniteMagnitude, y: -.greatestFiniteMagnitude),
            Vector2(x: Float32.infinity, y: -.infinity),
        ]
        let f = PackedVector2Array(vec2s)
        for (idx, v) in vec2s.enumerated() {
            XCTAssertEqual (v, f [idx])
        }
        
        let vec3s: [Vector3] = [
            Vector3(),
            Vector3(x: 0.3, y: .pi, z: 2.0 * .pi),
            Vector3(x: .greatestFiniteMagnitude, y: -.greatestFiniteMagnitude, z: 0),
            Vector3(x: Float32.infinity, y: -.infinity, z: 0),
        ]
        let g = PackedVector3Array(vec3s)
        for (idx, v) in vec3s.enumerated() {
            XCTAssertEqual (v, g [idx])
        }
        
        let vec4s: [Vector4] = [
            Vector4(),
            Vector4(x: 0.3, y: .pi, z: 2.0 * .pi, w: 1.0 / .pi),
            Vector4(x: .greatestFiniteMagnitude, y: -.greatestFiniteMagnitude, z: 0, w: -0),
            Vector4(x: Float32.infinity, y: -.infinity, z: 0, w: -0),
        ]
        let h = PackedVector4Array(vec4s)
        for (idx, v) in vec4s.enumerated() {
            XCTAssertEqual (v, h [idx])
        }
        
        let colors: [Color] = [ Color(), .red, .green, .blue, Color(r: 0.1, g: 0.2, b: 0.3, a: 0.4)]
        let i = PackedColorArray(colors)
        for (idx, v) in colors.enumerated() {
            XCTAssertEqual (v, i [idx])
        }
    }
    
    func testPackedByteArrayExtract () {
        let bytes: [UInt8] = [10, 20, 30, 255, 0, 3]
        let packed = PackedByteArray(bytes)
        let ret = packed.asBytes()
        XCTAssertEqual (ret, bytes)
    }
}
