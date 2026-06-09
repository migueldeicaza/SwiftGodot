//
//  BuiltinCodable.swift
//  SwiftGodot
//
//  Codable conformances for class-backed builtin types:
//  GString, StringName, NodePath, and all Packed*Array types.
//

// MARK: - GString

extension GString: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension GString: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(stringLiteral: string)
    }
}

// MARK: - StringName

extension StringName: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension StringName: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(stringLiteral: string)
    }
}

// MARK: - NodePath

extension NodePath: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension NodePath: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(stringLiteral: string)
    }
}

// MARK: - PackedByteArray

extension PackedByteArray: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedByteArray: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [UInt8] = []
        while !container.isAtEnd {
            elements.append(try container.decode(UInt8.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedInt32Array

extension PackedInt32Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedInt32Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Int32] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Int32.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedInt64Array

extension PackedInt64Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedInt64Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Int64] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Int64.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedFloat32Array

extension PackedFloat32Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedFloat32Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Float] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Float.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedFloat64Array

extension PackedFloat64Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedFloat64Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Double] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Double.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedStringArray

extension PackedStringArray: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedStringArray: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [String] = []
        while !container.isAtEnd {
            elements.append(try container.decode(String.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedVector2Array

extension PackedVector2Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedVector2Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Vector2] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Vector2.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedVector3Array

extension PackedVector3Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedVector3Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Vector3] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Vector3.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedColorArray

extension PackedColorArray: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedColorArray: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Color] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Color.self))
        }
        self.init(elements)
    }
}

// MARK: - PackedVector4Array

extension PackedVector4Array: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<Int(size()) {
            try container.encode(self[i])
        }
    }
}

extension PackedVector4Array: @retroactive Decodable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Vector4] = []
        while !container.isAtEnd {
            elements.append(try container.decode(Vector4.self))
        }
        self.init(elements)
    }
}
