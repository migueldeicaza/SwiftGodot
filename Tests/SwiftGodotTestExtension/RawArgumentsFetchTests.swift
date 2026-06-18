// NOTE: These tests verify that @Callable methods with various parameter types compile correctly.
// The tests use `node.call(method:...)` which goes through Godot's dynamic dispatch mechanism,
// not the direct RawArguments.fetchArgument path. However, the fact that the @Callable macro
// generates code that compiles is sufficient to verify that fetchArgument overload resolution
// works correctly for all tested types.

@testable import SwiftGodot

// MARK: - Custom GodotBuiltinConvertible types for testing

/// A custom type backed by Int
struct CustomIntWrapper: GodotBuiltinConvertible {
    let value: Int

    public func toGodotBuiltin() -> Int { value }

    public static func fromGodotBuiltinOrThrow(_ value: Int) throws(VariantConversionError) -> Self {
        CustomIntWrapper(value: value)
    }
}

/// A custom type backed by String
struct CustomStringWrapper: GodotBuiltinConvertible {
    let text: String

    public func toGodotBuiltin() -> String { text }

    public static func fromGodotBuiltinOrThrow(_ value: String) throws(VariantConversionError) -> Self {
        CustomStringWrapper(text: value)
    }
}

/// A custom type backed by Vector2
struct CustomVector2Wrapper: GodotBuiltinConvertible {
    let vec: Vector2

    public func toGodotBuiltin() -> Vector2 { vec }

    public static func fromGodotBuiltinOrThrow(_ value: Vector2) throws(VariantConversionError) -> Self {
        CustomVector2Wrapper(vec: value)
    }
}

// MARK: - Enums for RawRepresentable testing

enum TestIntEnum: Int {
    case first = 1
    case second = 2
    case third = 3
}

enum TestInt64Enum: Int64 {
    case alpha = 100
    case beta = 200
    case gamma = 300
}

// MARK: - Test Node with @Callable methods covering all fetchArgument paths

@Godot
class RawArgumentsTestNode: Node {

    // MARK: - Primitive types via _GodotBridgeableBuiltin

    @Callable
    func testInt(_ value: Int) -> Int {
        return value * 2
    }

    @Callable
    func testInt64(_ value: Int64) -> Int64 {
        return value * 2
    }

    @Callable
    func testBool(_ value: Bool) -> Bool {
        return !value
    }

    @Callable
    func testString(_ value: String) -> String {
        return value + "_suffix"
    }

    @Callable
    func testDouble(_ value: Double) -> Double {
        return value * 2.0
    }

    @Callable
    func testFloat(_ value: Float) -> Float {
        return value * 2.0
    }

    // MARK: - Generated builtin types via _GodotBridgeableBuiltin

    @Callable
    func testStringName(_ value: StringName) -> StringName {
        return StringName(String(value) + "_modified")
    }

    @Callable
    func testNodePath(_ value: NodePath) -> NodePath {
        return NodePath(String(value) + "/child")
    }

    @Callable
    func testVector2(_ value: Vector2) -> Vector2 {
        return value * 2.0
    }

    @Callable
    func testVector3(_ value: Vector3) -> Vector3 {
        return value * 2.0
    }

    @Callable
    func testVector4(_ value: Vector4) -> Vector4 {
        return value * 2.0
    }

    @Callable
    func testVector2i(_ value: Vector2i) -> Vector2i {
        return Vector2i(x: value.x * 2, y: value.y * 2)
    }

    @Callable
    func testVector3i(_ value: Vector3i) -> Vector3i {
        return Vector3i(x: value.x * 2, y: value.y * 2, z: value.z * 2)
    }

    @Callable
    func testVector4i(_ value: Vector4i) -> Vector4i {
        return Vector4i(x: value.x * 2, y: value.y * 2, z: value.z * 2, w: value.w * 2)
    }

    @Callable
    func testColor(_ value: Color) -> Color {
        return Color(r: value.red * 2.0, g: value.green * 2.0, b: value.blue * 2.0, a: value.alpha)
    }

    @Callable
    func testRect2(_ value: Rect2) -> Rect2 {
        return Rect2(position: value.position * 2.0, size: value.size * 2.0)
    }

    @Callable
    func testRect2i(_ value: Rect2i) -> Rect2i {
        return Rect2i(
            position: Vector2i(x: value.position.x * 2, y: value.position.y * 2),
            size: Vector2i(x: value.size.x * 2, y: value.size.y * 2)
        )
    }

    @Callable
    func testTransform2D(_ value: Transform2D) -> Transform2D {
        return value
    }

    @Callable
    func testTransform3D(_ value: Transform3D) -> Transform3D {
        return value
    }

    @Callable
    func testBasis(_ value: Basis) -> Basis {
        return value
    }

    @Callable
    func testQuaternion(_ value: Quaternion) -> Quaternion {
        return value
    }

    @Callable
    func testPlane(_ value: Plane) -> Plane {
        return value
    }

    @Callable
    func testAABB(_ value: AABB) -> AABB {
        return value
    }

    @Callable
    func testProjection(_ value: Projection) -> Projection {
        return value
    }

    @Callable
    func testRID(_ value: RID) -> RID {
        return value
    }

    @Callable
    func testCallable(_ value: Callable) -> Callable {
        return value
    }

    @Callable
    func testSignalArg(_ value: Signal) -> Signal {
        return value
    }

    // MARK: - Array types via _GodotBridgeableBuiltin

    @Callable
    func testVariantArray(_ value: VariantArray) -> Int {
        return value.count
    }

    @Callable
    func testVariantDictionary(_ value: VariantDictionary) -> Int {
        return Int(value.size())
    }

    @Callable
    func testPackedByteArray(_ value: PackedByteArray) -> Int {
        return value.count
    }

    @Callable
    func testPackedInt32Array(_ value: PackedInt32Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedInt64Array(_ value: PackedInt64Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedFloat32Array(_ value: PackedFloat32Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedFloat64Array(_ value: PackedFloat64Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedStringArray(_ value: PackedStringArray) -> Int {
        return value.count
    }

    @Callable
    func testPackedVector2Array(_ value: PackedVector2Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedVector3Array(_ value: PackedVector3Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedVector4Array(_ value: PackedVector4Array) -> Int {
        return value.count
    }

    @Callable
    func testPackedColorArray(_ value: PackedColorArray) -> Int {
        return value.count
    }

    // MARK: - TypedArray and TypedDictionary via _GodotBridgeableBuiltin

    @Callable
    func testTypedArrayInt(_ value: TypedArray<Int>) -> Int {
        return value.count
    }

    @Callable
    func testTypedArrayString(_ value: TypedArray<String>) -> Int {
        return value.count
    }

    @Callable
    func testTypedArrayObject(_ value: TypedArray<Node?>) -> Int {
        return value.count
    }

    @Callable
    func testTypedDictionaryIntString(_ value: TypedDictionary<Int, String>) -> Int {
        return Int(value.dictionary.size())
    }

    @Callable
    func testTypedDictionaryStringInt(_ value: TypedDictionary<String, Int>) -> Int {
        return Int(value.dictionary.size())
    }

    // MARK: - Swift Array and Dictionary via _GodotBridgeableBuiltin

    @Callable
    func testSwiftArrayInt(_ value: [Int]) -> Int {
        return value.reduce(0, +)
    }

    @Callable
    func testSwiftArrayString(_ value: [String]) -> String {
        return value.joined(separator: ",")
    }

    @Callable
    func testSwiftDictionaryIntString(_ value: [Int: String]) -> Int {
        return Int(value.keys.count)
    }

    @Callable
    func testSwiftDictionaryStringInt(_ value: [String: Int]) -> Int {
        return value.values.reduce(0, +)
    }

    // MARK: - Variant and Variant? (special overloads)

    @Callable
    func testVariant(_ value: Variant) -> String {
        return value.description
    }

    @Callable
    func testVariantOptional(_ value: Variant?) -> String {
        return value?.description ?? "nil"
    }

    // MARK: - Object types via Wrapped overloads

    @Callable
    func testNodeOptional(_ value: Node?) -> String {
        return value?.name.description ?? "nil"
    }

    @Callable
    func testNode(_ value: Node) -> String {
        return value.name.description
    }

    @Callable
    func testRefCountedOptional(_ value: RefCounted?) -> Bool {
        return value != nil
    }

    // MARK: - RawRepresentable enums

    @Callable
    func testIntEnum(_ value: TestIntEnum) -> Int {
        return value.rawValue * 10
    }

    @Callable
    func testInt64Enum(_ value: TestInt64Enum) -> Int64 {
        return value.rawValue * 10
    }

    // MARK: - GodotBuiltinConvertible custom types

    @Callable
    func testCustomIntWrapper(_ value: CustomIntWrapper) -> Int {
        return value.value * 3
    }

    @Callable
    func testCustomStringWrapper(_ value: CustomStringWrapper) -> String {
        return value.text.uppercased()
    }

    @Callable
    func testCustomVector2Wrapper(_ value: CustomVector2Wrapper) -> Vector2 {
        return value.vec * 3.0
    }

    // MARK: - Multiple parameters of different types

    @Callable
    func testMixedParams(
        intVal: Int,
        stringVal: String,
        boolVal: Bool,
        vec2Val: Vector2
    ) -> String {
        return "\(intVal)_\(stringVal)_\(boolVal)_\(vec2Val.x),\(vec2Val.y)"
    }

    @Callable
    func testMixedWithCustom(
        intWrapper: CustomIntWrapper,
        stringWrapper: CustomStringWrapper,
        normalInt: Int
    ) -> Int {
        return intWrapper.value + stringWrapper.text.count + normalInt
    }

    @Callable
    func testMixedWithArrays(
        typedArray: TypedArray<Int>,
        swiftArray: [String],
        packedArray: PackedFloat64Array
    ) -> Int {
        return typedArray.count + swiftArray.count + packedArray.count
    }

    @Callable
    func testMixedWithObjects(
        node: Node?,
        variant: Variant?,
        intEnum: TestIntEnum
    ) -> String {
        let nodeName = node?.name.description ?? "nil"
        let variantDesc = variant?.description ?? "nil"
        return "\(nodeName)_\(variantDesc)_\(intEnum.rawValue)"
    }
}

// MARK: - Test Suite

@SwiftGodotTestSuite
final class RawArgumentsFetchTests {
    public static var registeredTypes: [Object.Type] {
        return [RawArgumentsTestNode.self]
    }

    // MARK: - Primitive type tests

    func testFetchInt() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_int", Variant(42))
        assertEqual(Int(result), 84)
        node.queueFree()
    }

    func testFetchInt64() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_int64", Variant(Int64(100)))
        assertEqual(Int64(result), 200)
        node.queueFree()
    }

    func testFetchBool() {
        let node = RawArgumentsTestNode()
        let resultTrue = node.call(method: "test_bool", Variant(true))
        let resultFalse = node.call(method: "test_bool", Variant(false))
        assertEqual(Bool(resultTrue), false)
        assertEqual(Bool(resultFalse), true)
        node.queueFree()
    }

    func testFetchString() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_string", Variant("hello"))
        assertEqual(String(result), "hello_suffix")
        node.queueFree()
    }

    func testFetchDouble() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_double", Variant(3.14))
        assertEqual(Double(result)!, 6.28, accuracy: 0.001)
        node.queueFree()
    }

    func testFetchFloat() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_float", Variant(Float(2.5)))
        assertEqual(result?.gtype, .float)
        assertEqual(Float(result)!, 5.0, accuracy: 0.001)
        node.queueFree()
    }

    // MARK: - Generated builtin type tests

    func testFetchStringName() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_string_name", Variant(StringName("test")))
        assertEqual(String(StringName(result)!), "test_modified")
        node.queueFree()
    }

    func testFetchNodePath() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_node_path", Variant(NodePath("root/parent")))
        assertEqual(String(NodePath(result)!), "root/parent/child")
        node.queueFree()
    }

    func testFetchVector2() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector2", Variant(Vector2(x: 1, y: 2)))
        let vec = Vector2(result)!
        assertEqual(vec.x, 2)
        assertEqual(vec.y, 4)
        node.queueFree()
    }

    func testFetchVector3() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector3", Variant(Vector3(x: 1, y: 2, z: 3)))
        let vec = Vector3(result)!
        assertEqual(vec.x, 2)
        assertEqual(vec.y, 4)
        assertEqual(vec.z, 6)
        node.queueFree()
    }

    func testFetchVector4() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector4", Variant(Vector4(x: 1, y: 2, z: 3, w: 4)))
        let vec = Vector4(result)!
        assertEqual(vec.x, 2)
        assertEqual(vec.y, 4)
        assertEqual(vec.z, 6)
        assertEqual(vec.w, 8)
        node.queueFree()
    }

    func testFetchVector2i() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector2i", Variant(Vector2i(x: 3, y: 4)))
        let vec = Vector2i(result)!
        assertEqual(vec.x, 6)
        assertEqual(vec.y, 8)
        node.queueFree()
    }

    func testFetchVector3i() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector3i", Variant(Vector3i(x: 1, y: 2, z: 3)))
        let vec = Vector3i(result)!
        assertEqual(vec.x, 2)
        assertEqual(vec.y, 4)
        assertEqual(vec.z, 6)
        node.queueFree()
    }

    func testFetchVector4i() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_vector4i", Variant(Vector4i(x: 1, y: 2, z: 3, w: 4)))
        let vec = Vector4i(result)!
        assertEqual(vec.x, 2)
        assertEqual(vec.y, 4)
        assertEqual(vec.z, 6)
        assertEqual(vec.w, 8)
        node.queueFree()
    }

    func testFetchColor() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_color", Variant(Color(r: 0.25, g: 0.5, b: 0.125, a: 1.0)))
        let color = Color(result)!
        assertEqual(color.red, 0.5, accuracy: 0.001)
        assertEqual(color.green, 1.0, accuracy: 0.001)
        assertEqual(color.blue, 0.25, accuracy: 0.001)
        assertEqual(color.alpha, 1.0, accuracy: 0.001)
        node.queueFree()
    }

    func testFetchRect2() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_rect2", Variant(Rect2(position: Vector2(x: 1, y: 2), size: Vector2(x: 3, y: 4))))
        let rect = Rect2(result)!
        assertEqual(rect.position.x, 2)
        assertEqual(rect.position.y, 4)
        assertEqual(rect.size.x, 6)
        assertEqual(rect.size.y, 8)
        node.queueFree()
    }

    func testFetchRect2i() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_rect2i", Variant(Rect2i(position: Vector2i(x: 1, y: 2), size: Vector2i(x: 3, y: 4))))
        let rect = Rect2i(result)!
        assertEqual(rect.position.x, 2)
        assertEqual(rect.position.y, 4)
        assertEqual(rect.size.x, 6)
        assertEqual(rect.size.y, 8)
        node.queueFree()
    }

    func testFetchTransform2D() {
        let node = RawArgumentsTestNode()
        let transform = Transform2D()
        let result = node.call(method: "test_transform2d", Variant(transform))
        assertNotNil(Transform2D(result))
        node.queueFree()
    }

    func testFetchTransform3D() {
        let node = RawArgumentsTestNode()
        let transform = Transform3D()
        let result = node.call(method: "test_transform3d", Variant(transform))
        assertNotNil(Transform3D(result))
        node.queueFree()
    }

    func testFetchBasis() {
        let node = RawArgumentsTestNode()
        let basis = Basis()
        let result = node.call(method: "test_basis", Variant(basis))
        assertNotNil(Basis(result))
        node.queueFree()
    }

    func testFetchQuaternion() {
        let node = RawArgumentsTestNode()
        let quat = Quaternion()
        let result = node.call(method: "test_quaternion", Variant(quat))
        assertNotNil(Quaternion(result))
        node.queueFree()
    }

    func testFetchPlane() {
        let node = RawArgumentsTestNode()
        let plane = Plane()
        let result = node.call(method: "test_plane", Variant(plane))
        assertNotNil(Plane(result))
        node.queueFree()
    }

    func testFetchAABB() {
        let node = RawArgumentsTestNode()
        let aabb = AABB()
        let result = node.call(method: "test_aabb", Variant(aabb))
        assertNotNil(AABB(result))
        node.queueFree()
    }

    func testFetchProjection() {
        let node = RawArgumentsTestNode()
        let projection = Projection()
        let result = node.call(method: "test_projection", Variant(projection))
        assertNotNil(Projection(result))
        node.queueFree()
    }

    func testFetchRID() {
        let node = RawArgumentsTestNode()
        let rid = RID()
        let result = node.call(method: "test_rid", Variant(rid))
        assertNotNil(RID(result))
        node.queueFree()
    }

    func testFetchCallable() {
        let node = RawArgumentsTestNode()
        let callable = Callable()
        let result = node.call(method: "test_callable", Variant(callable))
        assertNotNil(Callable(result))
        node.queueFree()
    }

    func testFetchSignal() {
        let node = RawArgumentsTestNode()
        let signal = Signal()
        let result = node.call(method: "test_signal_arg", Variant(signal))
        assertNotNil(Signal(result))
        node.queueFree()
    }

    // MARK: - Array type tests

    func testFetchVariantArray() {
        let node = RawArgumentsTestNode()
        let array = VariantArray()
        array.append(Variant(1))
        array.append(Variant(2))
        array.append(Variant(3))
        let result = node.call(method: "test_variant_array", Variant(array))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    func testFetchVariantDictionary() {
        let node = RawArgumentsTestNode()
        let dict = VariantDictionary()
        dict["a"] = Variant(1)
        dict["b"] = Variant(2)
        let result = node.call(method: "test_variant_dictionary", Variant(dict))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchPackedByteArray() {
        let node = RawArgumentsTestNode()
        var array = PackedByteArray()
        array.append(1)
        array.append(2)
        array.append(3)
        let result = node.call(method: "test_packed_byte_array", Variant(array))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    func testFetchPackedInt32Array() {
        let node = RawArgumentsTestNode()
        var array = PackedInt32Array()
        array.append(1)
        array.append(2)
        let result = node.call(method: "test_packed_int32_array", Variant(array))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchPackedInt64Array() {
        let node = RawArgumentsTestNode()
        var array = PackedInt64Array()
        array.append(1)
        array.append(2)
        array.append(3)
        array.append(4)
        let result = node.call(method: "test_packed_int64_array", Variant(array))
        assertEqual(Int(result), 4)
        node.queueFree()
    }

    func testFetchPackedFloat32Array() {
        let node = RawArgumentsTestNode()
        var array = PackedFloat32Array()
        array.append(1.0)
        array.append(2.0)
        let result = node.call(method: "test_packed_float32_array", Variant(array))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchPackedFloat64Array() {
        let node = RawArgumentsTestNode()
        var array = PackedFloat64Array()
        array.append(1.0)
        array.append(2.0)
        array.append(3.0)
        let result = node.call(method: "test_packed_float64_array", Variant(array))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    func testFetchPackedStringArray() {
        let node = RawArgumentsTestNode()
        var array = PackedStringArray()
        array.append("a")
        array.append("b")
        let result = node.call(method: "test_packed_string_array", Variant(array))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchPackedVector2Array() {
        let node = RawArgumentsTestNode()
        var array = PackedVector2Array()
        array.append(Vector2(x: 1, y: 2))
        let result = node.call(method: "test_packed_vector2_array", Variant(array))
        assertEqual(Int(result), 1)
        node.queueFree()
    }

    func testFetchPackedVector3Array() {
        let node = RawArgumentsTestNode()
        var array = PackedVector3Array()
        array.append(Vector3(x: 1, y: 2, z: 3))
        array.append(Vector3(x: 4, y: 5, z: 6))
        let result = node.call(method: "test_packed_vector3_array", Variant(array))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchPackedVector4Array() {
        let node = RawArgumentsTestNode()
        var array = PackedVector4Array()
        array.append(value: Vector4(x: 1, y: 2, z: 3, w: 4))
        let result = node.call(method: "test_packed_vector4_array", Variant(array))
        assertEqual(Int(result), 1)
        node.queueFree()
    }

    func testFetchPackedColorArray() {
        let node = RawArgumentsTestNode()
        var array = PackedColorArray()
        array.append(Color.red)
        array.append(Color.green)
        array.append(Color.blue)
        let result = node.call(method: "test_packed_color_array", Variant(array))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    // MARK: - TypedArray and TypedDictionary tests

    func testFetchTypedArrayInt() {
        let node = RawArgumentsTestNode()
        let array = TypedArray<Int>()
        array.append(1)
        array.append(2)
        array.append(3)
        let result = node.call(method: "test_typed_array_int", Variant(array.array))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    func testFetchTypedArrayString() {
        let node = RawArgumentsTestNode()
        let array = TypedArray<String>()
        array.append("hello")
        array.append("world")
        let result = node.call(method: "test_typed_array_string", Variant(array.array))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchTypedDictionaryIntString() {
        let node = RawArgumentsTestNode()
        let dict = TypedDictionary<Int, String>()
        dict[1] = "one"
        dict[2] = "two"
        let result = node.call(method: "test_typed_dictionary_int_string", Variant(dict.dictionary))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchTypedDictionaryStringInt() {
        let node = RawArgumentsTestNode()
        let dict = TypedDictionary<String, Int>()
        dict["a"] = 1
        dict["b"] = 2
        dict["c"] = 3
        let result = node.call(method: "test_typed_dictionary_string_int", Variant(dict.dictionary))
        assertEqual(Int(result), 3)
        node.queueFree()
    }

    // MARK: - Swift Array and Dictionary tests

    func testFetchSwiftArrayInt() {
        let node = RawArgumentsTestNode()
        let swiftArray: [Int] = [1, 2, 3, 4, 5]
        let typedArray = TypedArray<Int>(swiftArray)
        let result = node.call(method: "test_swift_array_int", Variant(typedArray.array))
        assertEqual(Int(result), 15) // 1+2+3+4+5 = 15
        node.queueFree()
    }

    func testFetchSwiftArrayString() {
        let node = RawArgumentsTestNode()
        let swiftArray: [String] = ["a", "b", "c"]
        let typedArray = TypedArray<String>(swiftArray)
        let result = node.call(method: "test_swift_array_string", Variant(typedArray.array))
        assertEqual(String(result), "a,b,c")
        node.queueFree()
    }

    func testFetchSwiftDictionaryIntString() {
        let node = RawArgumentsTestNode()
        let swiftDict: [Int: String] = [1: "one", 2: "two"]
        let typedDict = TypedDictionary<Int, String>(swiftDict)
        let result = node.call(method: "test_swift_dictionary_int_string", Variant(typedDict.dictionary))
        assertEqual(Int(result), 2)
        node.queueFree()
    }

    func testFetchSwiftDictionaryStringInt() {
        let node = RawArgumentsTestNode()
        let swiftDict: [String: Int] = ["a": 10, "b": 20, "c": 30]
        let typedDict = TypedDictionary<String, Int>(swiftDict)
        let result = node.call(method: "test_swift_dictionary_string_int", Variant(typedDict.dictionary))
        assertEqual(Int(result), 60) // 10+20+30 = 60
        node.queueFree()
    }

    // MARK: - Variant tests

    func testFetchVariant() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_variant", Variant(42))
        assertEqual(String(result), "42")
        node.queueFree()
    }

    func testFetchVariantOptionalWithValue() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_variant_optional", Variant("hello"))
        assertEqual(String(result), "hello")
        node.queueFree()
    }

    // MARK: - Object tests

    func testFetchNodeOptionalWithValue() {
        let node = RawArgumentsTestNode()
        let testNode = Node()
        testNode.name = "TestNode"
        let result = node.call(method: "test_node_optional", Variant(testNode))
        assertEqual(String(result), "TestNode")
        testNode.queueFree()
        node.queueFree()
    }

    func testFetchNode() {
        let node = RawArgumentsTestNode()
        let testNode = Node()
        testNode.name = "MyTestNode"
        let result = node.call(method: "test_node", Variant(testNode))
        assertEqual(String(result), "MyTestNode")
        testNode.queueFree()
        node.queueFree()
    }

    func testFetchRefCountedOptional() {
        let node = RawArgumentsTestNode()
        let refCounted = RefCounted()
        let result = node.call(method: "test_ref_counted_optional", Variant(refCounted))
        assertEqual(Bool(result), true)
        node.queueFree()
    }

    // MARK: - RawRepresentable enum tests

    func testFetchIntEnum() {
        let node = RawArgumentsTestNode()
        // Pass the raw value since Godot doesn't know about our Swift enum
        let result = node.call(method: "test_int_enum", Variant(2)) // TestIntEnum.second
        assertEqual(Int(result), 20) // 2 * 10 = 20
        node.queueFree()
    }

    func testFetchInt64Enum() {
        let node = RawArgumentsTestNode()
        let result = node.call(method: "test_int64_enum", Variant(200)) // TestInt64Enum.beta
        assertEqual(Int64(result), 2000) // 200 * 10 = 2000
        node.queueFree()
    }

    // MARK: - GodotBuiltinConvertible custom type tests

    func testFetchCustomIntWrapper() {
        let node = RawArgumentsTestNode()
        // CustomIntWrapper is backed by Int, so we pass an Int
        let result = node.call(method: "test_custom_int_wrapper", Variant(7))
        assertEqual(Int(result), 21) // 7 * 3 = 21
        node.queueFree()
    }

    func testFetchCustomStringWrapper() {
        let node = RawArgumentsTestNode()
        // CustomStringWrapper is backed by String
        let result = node.call(method: "test_custom_string_wrapper", Variant("hello"))
        assertEqual(String(result), "HELLO")
        node.queueFree()
    }

    func testFetchCustomVector2Wrapper() {
        let node = RawArgumentsTestNode()
        // CustomVector2Wrapper is backed by Vector2
        let result = node.call(method: "test_custom_vector2_wrapper", Variant(Vector2(x: 2, y: 3)))
        let vec = Vector2(result)!
        assertEqual(vec.x, 6) // 2 * 3 = 6
        assertEqual(vec.y, 9) // 3 * 3 = 9
        node.queueFree()
    }

    // MARK: - Mixed parameter tests

    func testFetchMixedParams() {
        let node = RawArgumentsTestNode()
        let result = node.call(
            method: "test_mixed_params",
            Variant(42),
            Variant("test"),
            Variant(true),
            Variant(Vector2(x: 1.5, y: 2.5))
        )
        assertEqual(String(result), "42_test_true_1.5,2.5")
        node.queueFree()
    }

    func testFetchMixedWithCustom() {
        let node = RawArgumentsTestNode()
        // intWrapper(5) + stringWrapper("abc").count(3) + normalInt(10) = 18
        let result = node.call(
            method: "test_mixed_with_custom",
            Variant(5),      // CustomIntWrapper
            Variant("abc"),  // CustomStringWrapper
            Variant(10)      // normal Int
        )
        assertEqual(Int(result), 18)
        node.queueFree()
    }

    func testFetchMixedWithArrays() {
        let node = RawArgumentsTestNode()

        let typedArray = TypedArray<Int>()
        typedArray.append(1)
        typedArray.append(2)

        let swiftArray = TypedArray<String>(["a", "b", "c"])

        var packedArray = PackedFloat64Array()
        packedArray.append(1.0)

        // 2 + 3 + 1 = 6
        let result = node.call(
            method: "test_mixed_with_arrays",
            Variant(typedArray.array),
            Variant(swiftArray.array),
            Variant(packedArray)
        )
        assertEqual(Int(result), 6)
        node.queueFree()
    }

    func testFetchMixedWithObjects() {
        let node = RawArgumentsTestNode()
        let testNode = Node()
        testNode.name = "ObjNode"

        let result = node.call(
            method: "test_mixed_with_objects",
            Variant(testNode),
            Variant(123),
            Variant(3) // TestIntEnum.third
        )
        assertEqual(String(result), "ObjNode_123_3")
        testNode.queueFree()
        node.queueFree()
    }
}
