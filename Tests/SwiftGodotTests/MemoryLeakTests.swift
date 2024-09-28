import SwiftGodot
import SwiftGodotTestability
import XCTest

struct Foo: Codable {
    var myInt: Int
    var myText: String
    var myIntArray: [Int]
}

struct FooN: Codable {
    var myInt: Int
    var myText: String
    var myFoo: [Foo]
}

protocol GodotEncodingContainer {
    var data: Variant { get }
}

extension Vector2: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    public init (from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(Float.self, forKey: .x)
        let y = try values.decode(Float.self, forKey: .y)
        self.init (x: x, y: y)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(x, forKey: .y)
    }
}

/// Notes on encoding:
///   - Int8 is encoded as an Int
class GodotEncoder: Encoder {
    var codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var container: GodotEncodingContainer? = nil

    init () {

    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {

        var container = GodotKeyedContainer<Key>(codingPath: codingPath, userInfo: userInfo)
        self.container = container
        return KeyedEncodingContainer(container)
    }

    var data: Variant {
        return container?.data ?? Variant()
    }

    func encode(key codingKey: [CodingKey], value: Variant) {
        let key = codingKey.map { $0.stringValue }.joined(separator: ".")
        fatalError()
        //dict [key] = value
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        let container = GodotUnkeyedContainer(codingPath: codingPath, userInfo: userInfo)
        self.container = container
        return container
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        let container = GodotSingleValueContainer(codingPath: codingPath, userInfo: userInfo)
        self.container = container
        return container
    }

    class GodotKeyedContainer<Key:CodingKey>: KeyedEncodingContainerProtocol, GodotEncodingContainer {
        func encodeNil(forKey key: Key) throws {
            var container = self.nestedSingleValueContainer(forKey: key)
            fatalError()
            //try container.encode(Variant())
        }

        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any]
        var storage: [String:GodotEncodingContainer] = [:]

        var data: Variant {
            let dict = GDictionary()
            for (k,v) in storage {
                dict[k] = Variant(v.data)
            }
            return Variant(dict)
        }

        init (codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func encode(_ value: String, forKey key: Key) throws {
            var container = self.nestedSingleValueContainer(forKey: key)
            try container.encode(value)
            self.storage[key.stringValue] = container
        }

        func encode(_ value: Int, forKey key: Key) throws {
            let container = self.nestedSingleValueContainer(forKey: key)
            try container.encode(value)
            self.storage[key.stringValue] = container
        }

        func nestedSingleValueContainer(forKey key: Key)
            -> GodotSingleValueContainer
        {
            let container = GodotSingleValueContainer(
                codingPath: self.codingPath + [key],
                userInfo: self.userInfo
            )
            return container
        }

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            let container = self.nestedSingleValueContainer(forKey: key)
            try container.encode(value)
            self.storage[key.stringValue] = container

        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            fatalError()
        }

        func superEncoder() -> any Encoder {
            fatalError()
        }

        func superEncoder(forKey key: Key) -> any Encoder {
            fatalError()
        }
    }

    class GodotUnkeyedContainer: UnkeyedEncodingContainer, GodotEncodingContainer {
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any]

        var storage = GArray()

        var data: Variant {
            return Variant(storage)
        }

        init (codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        var count: Int {
            Int(storage.size())
        }

        func encode(_ value: String) throws {
            fatalError()
        }

        func encode(_ value: Double) throws {
            fatalError()
        }

        func encode(_ value: Float) throws {
            fatalError()
        }

        func encode(_ value: Int) throws {
            fatalError()
        }

        func encode(_ value: Int8) throws {
            fatalError()
        }

        func encode(_ value: Int16) throws {
            fatalError()
        }

        func encode(_ value: Int32) throws {
            fatalError()
        }

        func encode(_ value: Int64) throws {
            fatalError()
        }

        func encode(_ value: UInt) throws {
            fatalError()
        }

        func encode(_ value: UInt8) throws {
            fatalError()
        }

        func encode(_ value: UInt16) throws {
            fatalError()
        }

        func encode(_ value: UInt32) throws {
            fatalError()
        }

        func encode(_ value: UInt64) throws {
            fatalError()
        }

        func encode<T>(_ value: T) throws where T: Encodable {
            let base = Int(storage.size())


            if let v = value as? Array<Encodable> {
                _ = storage.resize(size: storage.size () + Int64(v.count))
                for i in 0..<v.count {
                    let v = v [i]
                    let nested = GodotSingleValueContainer(codingPath: codingPath, userInfo: userInfo)
                    try nested.encode(v)
                    storage [base+i] = nested.data
                }
            } else {
                _ = storage.resize(size: storage.size () + 1)
                let nested = GodotSingleValueContainer(codingPath: codingPath, userInfo: userInfo)
                try nested.encode (value)
                storage [base] = nested.data
            }
        }

        func encode(_ value: Bool) throws {
            fatalError()
        }

        private struct IndexedCodingKey: CodingKey {
            let intValue: Int?
            let stringValue: String

            init?(intValue: Int) {
                self.intValue = intValue
                self.stringValue = intValue.description
            }

            init?(stringValue: String) {
                return nil
            }
        }

        func encodeNil() throws {
            fatalError()
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            fatalError()
        }

        func superEncoder() -> any Encoder {
            fatalError()
        }


    }

    class GodotSingleValueContainer: SingleValueEncodingContainer, GodotEncodingContainer {
        func encode<T>(_ value: T) throws where T : Encodable {
            if value is Array<Any> {
                var container = GodotUnkeyedContainer (codingPath: codingPath, userInfo: userInfo)
                try container.encode(value)
                self.value = container.data
            } else if let i = value as? Int {
                try self.encode(i)
            } else if let str = value as? String {
                try self.encode(str)
            } else {
                var nested = GodotEncoder()
                try value.encode(to: nested)
                self.value = nested.container?.data
            }
        }

        enum foo: Error {
            case nope
        }

        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any]
        var value: Variant?

        var data: Variant {
            value ?? Variant()
        }

        init (codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func encodeNil() throws {
            fatalError()
        }

        func encode(_ value: Bool) throws {
            fatalError()
        }

        func encode(_ value: String) throws {
            self.value = Variant(value)
        }

        func encode(_ value: Double) throws {
            fatalError()
        }

        func encode(_ value: Float) throws {
            fatalError()
        }

        func encode(_ value: Int) throws {
            self.value = Variant(Int(value))
        }

        func encode(_ value: Int8) throws {
            fatalError()
        }

        func encode(_ value: Int16) throws {
            fatalError()
        }

        func encode(_ value: Int32) throws {
            fatalError()
        }

        func encode(_ value: Int64) throws {
            fatalError()
        }

        func encode(_ value: UInt) throws {
            fatalError()
        }

        func encode(_ value: UInt8) throws {
            fatalError()
        }

        func encode(_ value: UInt16) throws {
            fatalError()
        }

        func encode(_ value: UInt32) throws {
            fatalError()
        }

        func encode(_ value: UInt64) throws {
            fatalError()
        }
    }
}

final class MemoryLeakTests: GodotTestCase {
    /// Check that `body` doesn't leak. Or ensure that something is leaking, if `useUnoReverseCard` is true
    func checkLeaks(useUnoReverseCard: Bool = false, _ body: () -> Void) {
        let before = Performance.getMonitor(.memoryStatic)
        body()
        let after = Performance.getMonitor(.memoryStatic)
        
        if useUnoReverseCard {
            XCTAssertNotEqual(before, after, "It should leak!")
        } else {
            XCTAssertEqual(before, after, "Leaked \(after - before) bytes")
        }
    }
    
    func testThatItLeaksIndeed() {
        let array = GArray()
        
        checkLeaks(useUnoReverseCard: true) {
            array.append(Variant(10))
        }
    }

    // https://github.com/migueldeicaza/SwiftGodot/issues/513
    func test_513_leak1() {
        func oneIteration(object: Object) {
            let list = object.getPropertyList()
            let it = list.makeIterator()
            for prop: GDictionary in it {
                _ = prop
            }
        }

        let object = Object()

        // Warm-up the code path in case it performs any one-time permanent allocations.
        oneIteration(object: object)
        
        checkLeaks {
            for _ in 0 ..< 1_000 {
                oneIteration(object: object)
            }
        }
    }

    // https://github.com/migueldeicaza/SwiftGodot/issues/513
    func test_513_leak2() {

        func oneIteration(bytes: PackedByteArray) {
            let image0 = SwiftGodot.Image()
            let variant = Variant(image0)
            let image: SwiftGodot.Image = variant.asObject()!
            _ = image.loadPngFromBuffer(bytes)
            // Doesn't leak with line below uncommented
            // image.unreference()
        }

        let bytes = PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 1, 3, 0, 0, 0, 37, 219, 86, 202, 0, 0, 0, 3, 80, 76, 84, 69, 0, 0, 0, 167, 122, 61, 218, 0, 0, 0, 1, 116, 82, 78, 83, 0, 64, 230, 216, 102, 0, 0, 0, 10, 73, 68, 65, 84, 8, 215, 99, 96, 0, 0, 0, 2, 0, 1, 226, 33, 188, 51, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130])

        // Warm-up the code path in case it performs any one-time permanent allocations.
        oneIteration(bytes: bytes)

        checkLeaks {
            for _ in 0 ..< 1_000 {
                oneIteration(bytes: bytes)
            }
        }
    }
  
    // https://github.com/migueldeicaza/SwiftGodot/issues/541
    func test_541_leak() {
        checkLeaks {
            for _ in 0...1_000 {
                let _ = Variant("daosdoasodasoda")
            }
        }
    }
  
    // https://github.com/migueldeicaza/SwiftGodot/issues/544
    func test_544_leak() {
        let string = "Hello, World!"
        let variant = Variant(string)

        // https://docs.godotengine.org/en/stable/classes/class_string.html#class-string-method-left
        let methodName = StringName("left")

        checkLeaks {
            for _ in 0 ..< 2_000 {
                let _ = variant.call(method: methodName, Variant(2))
            }
        }
    }
    
    // https://github.com/migueldeicaza/SwiftGodot/issues/543
    func test_543_leak() {
        let string = "Hello, World!"
        let variant = Variant(string)

        checkLeaks {
            for _ in 0 ..< 2000 {
                _ = variant[0]
            }
        }
    }
    
    func test_array_leaks() {
        let array = GArray()
        array.append(Variant("S"))
        array.append(Variant("M"))
        
        checkLeaks {
            XCTAssertEqual(array[0], Variant("S"))
            
            for _ in 0 ..< 1_000 {
                array[0] = Variant("T")
                _ = array[1]
            }
        }
        
        XCTAssertEqual(array[0], Variant("T"))
        
        let variant = Variant(array)
        
        checkLeaks {
            XCTAssertEqual(variant[0], Variant("T"))
            
            for _ in 0 ..< 1_000 {
                variant[0] = Variant("U")
                variant[1] = Variant("K")
            }
            
            XCTAssertEqual(variant[1], Variant("K"))
        }
        
        XCTAssertEqual(variant[0], Variant("U"))
    }
    
    func test_emit_signal_leak() {
        let object = Object()
        let signal = SignalWithNoArguments("some_random_name")
        
        checkLeaks {
            for _ in 0 ..< 200 {
                _ = object.emit(signal: signal)
            }
        }
    }
    
    func test_gstring_string_variant_leak() {
        let gstrFoo = GString("Foo")
        
        checkLeaks {
            for _ in 0 ..< 200 {
                let strFoo = String(gstrFoo)
                let varFoo = Variant(gstrFoo)
                let strFoo0 = varFoo.description
                guard let gstrFoo0 = GString(varFoo) else {
                    XCTFail()
                    
                    return
                }
                let strFoo1 = String(gstrFoo0)
            }
        }
        
        checkLeaks {
            for _ in 0 ..< 200 {
                let gstrBar = GString("Bar")
                
                let strBar = String(gstrBar)
                let varBar = Variant(gstrBar)
                let strBar0 = varBar.description
                guard let gstrBar0 = GString(varBar) else {
                    XCTFail()
                    
                    return
                }
                let strBar1 = String(gstrBar0)
            }
        }
    }
    
    // https://github.com/migueldeicaza/SwiftGodot/issues/551
    func test_551_leak() {
        checkLeaks {
            for i in 0 ..< 200 {
                let str = GD.str(arg1: Variant(i))
                XCTAssertEqual("\(i)", str)
            }
        }
    }
    
    // https://github.com/migueldeicaza/SwiftGodot/issues/552
    func test_552_leak() {
        checkLeaks {
            for _ in 0 ..< 200 {
                let object = Object()
                let methodName = StringName("get_method_list")
                let methodList = object.call(method: methodName)
            }
        }
    }
    
    func test_godot_string_description_leak() {
        checkLeaks {
            let string = GString("A")
            for _ in 0 ..< 100 {
                print(string.description)
            }
        }
    }
    
    func test_godot_string_from_variant_leak() {
        let variant = Variant("A")
        checkLeaks {
            for _ in 0 ..< 100 {
                guard let gstring = GString(variant) else {
                    XCTFail()
                    break
                }
                
                print(gstring.description)
            }
        }
    }
    
    func test_531_crash_or_leak() {
        checkLeaks {
            let g = GodotEncoder()
            let foon = FooN(myInt: 9, myText: "nine", myFoo: [
                Foo(myInt: 10, myText: "Nested1", myIntArray: [1,1,1]),
                Foo(myInt: 30, myText: "Nested2", myIntArray: [2,2,2])])
            try? foon.encode(to: g)
            
            print(g.data.description)
        }
    }
    
    func test_dictionary_leaks() {
        checkLeaks {
            let dictionary = GDictionary()
            
            for i in 0 ..< 1_000 {
                let variant = Variant("value\(i)")
                dictionary["key\(i * 2)"] = variant
                dictionary["key\(i * 2 + 1)"] = variant
            }
            
            for i in 0 ..< 1_000 {
                let key = "key\(Int.random(in: 0 ..< 2_000))"
                let value = dictionary[key]                
                dictionary["key\(i * 2)"] = value
            }
            
            for i in 0 ..< 1_000 {
                _ = dictionary.erase(key: Variant("\(i * 2)"))
            }
            
            dictionary.clear()
        }
    }
}
