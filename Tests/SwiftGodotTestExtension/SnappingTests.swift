@testable import SwiftGodot

@SwiftGodotTestSuite
final class SnappingTests {
    public func testSnapDouble() {
        assertEqual(Double(0).snapped(step: 10), 0)
        assertEqual(Double(1).snapped(step: 10), 0)
        assertEqual(Double(5).snapped(step: 10), 10)
        assertEqual(Double(9).snapped(step: 10), 10)
        assertEqual(Double(10).snapped(step: 10), 10)
        assertEqual(Double(1.1).snapped(step: 1), 1)
        assertEqual(Double(1.49).snapped(step: 1), 1)
        assertEqual(Double(1.5).snapped(step: 1), 2)
        assertEqual(Double(1.9).snapped(step: 1), 2)
        assertEqual(Double(1.7).snapped(step: 3.5), 0)
        assertEqual(Double(1.75).snapped(step: 3.5), 3.5)
        assertEqual(Double(1.1).snapped(step: 0), 1.1)

        assertEqual(Double(-1).snapped(step: 10), 0)
        assertEqual(Double(-5).snapped(step: 10), 0)
        assertEqual(Double(-5.1).snapped(step: 10), -10)
        assertEqual(Double(-9).snapped(step: 10), -10)
        assertEqual(Double(-10).snapped(step: 10), -10)
        assertEqual(Double(-1.1).snapped(step: 1), -1)
        assertEqual(Double(-1.49).snapped(step: 1), -1)
        assertEqual(Double(-1.5).snapped(step: 1), -1)
        assertEqual(Double(-1.51).snapped(step: 1), -2)
        assertEqual(Double(-1.9).snapped(step: 1), -2)
        assertEqual(Double(-1.75).snapped(step: 3.5), 0)
        assertEqual(Double(-1.751).snapped(step: 3.5), -3.5)
        assertEqual(Double(-1.1).snapped(step: 0), -1.1)

        assertEqual(Double(1008).snapped(step: 1000), 1000)
        assertEqual(Double(4023).snapped(step: 1000), 4000)
        assertEqual(Double(128).snapped(step: 128), 128)
        assertEqual(Double(128).snapped(step: 200), 200)
    }

    public func testSnapFloat() {
        assertEqual(Float(1008).snapped(step: 1000), 1000)
        assertEqual(Float(4023).snapped(step: 1000), 4000)
        assertEqual(Float(128).snapped(step: 128), 128)
        assertEqual(Float(128).snapped(step: 200), 200)
    }

    public func testSnapInt() {
        assertEqual(Int(0).snapped(step: 10), 0)
        assertEqual(Int(1).snapped(step: 10), 0)
        assertEqual(Int(5).snapped(step: 10), 10)
        assertEqual(Int(9).snapped(step: 10), 10)
        assertEqual(Int(10).snapped(step: 10), 10)

        assertEqual(Int(-1).snapped(step: 10), 0)
        assertEqual(Int(-5).snapped(step: 10), 0)
        assertEqual(Int(-6).snapped(step: 10), -10)
        assertEqual(Int(-9).snapped(step: 10), -10)
        assertEqual(Int(-10).snapped(step: 10), -10)

        assertEqual(Int(1008).snapped(step: 1000), 1000)
        assertEqual(Int(4023).snapped(step: 1000), 4000)
        assertEqual(Int(128).snapped(step: 128), 128)
        assertEqual(Int(128).snapped(step: 200), 200)
    }

    public func testSnapVector4() {
        assertEqual(Vector4(x: 1008, y: 1008, z: 1008, w: 1008)
            .snapped(step: Vector4(x: 1000, y: 1000, z: 1000, w: 1000)),
                       Vector4(x: 1000, y: 1000, z: 1000, w: 1000))
        assertEqual(Vector4(x: 4023, y: 4023, z: 4023, w: 4023)
            .snapped(step: Vector4(x: 1000, y: 1000, z: 1000, w: 1000)),
                       Vector4(x: 4000, y: 4000, z: 4000, w: 4000))
        assertEqual(Vector4(x: 128, y: 128, z: 128, w: 128)
            .snapped(step: Vector4(x: 128, y: 128, z: 128, w: 128)),
                       Vector4(x: 128, y: 128, z: 128, w: 128))
        assertEqual(Vector4(x: 128, y: 128, z: 128, w: 128)
            .snapped(step: Vector4(x: 1000, y: 1000, z: 1000, w: 1000)),
                       Vector4(x: 0, y: 0, z: 0, w: 0))
    }

    public func testSnapVector3() {
        assertEqual(Vector3(x: 1008, y: 1008, z: 1008)
            .snapped(step: Vector3(x: 1000, y: 1000, z: 1000)), Vector3(x: 1000, y: 1000, z: 1000))
        assertEqual(Vector3(x: 4023, y: 4023, z: 4023)
            .snapped(step: Vector3(x: 1000, y: 1000, z: 1000)), Vector3(x: 4000, y: 4000, z: 4000))
        assertEqual(Vector3(x: 128, y: 128, z: 128)
            .snapped(step: Vector3(x: 128, y: 128, z: 128)), Vector3(x: 128, y: 128, z: 128))
        assertEqual(Vector3(x: 128, y: 128, z: 128)
            .snapped(step: Vector3(x: 1000, y: 1000, z: 1000)), Vector3(x: 0, y: 0, z: 0))
    }

    public func testSnapVector2() {
        assertEqual(Vector2(x: 1008, y: 1008)
            .snapped(step: Vector2(x: 1000, y: 1000)), Vector2(x: 1000, y: 1000))
        assertEqual(Vector2(x: 4023, y: 4023)
            .snapped(step: Vector2(x: 1000, y: 1000)), Vector2(x: 4000, y: 4000))
        assertEqual(Vector2(x: 128, y: 128)
            .snapped(step: Vector2(x: 128, y: 128)), Vector2(x: 128, y: 128))
        assertEqual(Vector2(x: 128, y: 128)
            .snapped(step: Vector2(x: 1000, y: 1000)), Vector2(x: 0, y: 0))
    }
}
