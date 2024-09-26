//
//  EncodingTests.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 26/09/2024.
//

import XCTest
import SwiftGodotTestability
import SwiftGodot

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


final class EncodingTests: GodotTestCase {
    func testEncoding() {
        let g = GodotEncoder()
        let foon = FooN(myInt: 9, myText: "nine", myFoo: [
            Foo(myInt: 10, myText: "Nested1", myIntArray: [1,1,1]),
            Foo(myInt: 30, myText: "Nested2", myIntArray: [2,2,2])])
        try? foon.encode (to:g)
        
        print(g.data)
    }
}
