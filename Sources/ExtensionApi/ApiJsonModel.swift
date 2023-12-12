// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jGodotExtensionAPI = try? JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)

import Foundation

// MARK: - JGodotExtensionAPI
public struct JGodotExtensionAPI: Codable {
    public let header: JGodotHeader
    public let builtinClassSizes: [JGodotBuiltinClassSize]
    public let builtinClassMemberOffsets: [JGodotBuiltinClassMemberOffset]
    public let globalConstants: [JSONAny]
    public let globalEnums: [JGodotGlobalEnumElement]
    public let utilityFunctions: [JGodotUtilityFunction]
    public let builtinClasses: [JGodotBuiltinClass]
    public let classes: [JGodotExtensionAPIClass]
    public let singletons: [JGodotArgument]
    public let nativeStructures: [JGodotNativeStructure]

    enum CodingKeys: String, CodingKey {
        case header
        case builtinClassSizes = "builtin_class_sizes"
        case builtinClassMemberOffsets = "builtin_class_member_offsets"
        case globalConstants = "global_constants"
        case globalEnums = "global_enums"
        case utilityFunctions = "utility_functions"
        case builtinClasses = "builtin_classes"
        case classes, singletons
        case nativeStructures = "native_structures"
    }

    public init(header: JGodotHeader, builtinClassSizes: [JGodotBuiltinClassSize], builtinClassMemberOffsets: [JGodotBuiltinClassMemberOffset], globalConstants: [JSONAny], globalEnums: [JGodotGlobalEnumElement], utilityFunctions: [JGodotUtilityFunction], builtinClasses: [JGodotBuiltinClass], classes: [JGodotExtensionAPIClass], singletons: [JGodotArgument], nativeStructures: [JGodotNativeStructure]) {
        self.header = header
        self.builtinClassSizes = builtinClassSizes
        self.builtinClassMemberOffsets = builtinClassMemberOffsets
        self.globalConstants = globalConstants
        self.globalEnums = globalEnums
        self.utilityFunctions = utilityFunctions
        self.builtinClasses = builtinClasses
        self.classes = classes
        self.singletons = singletons
        self.nativeStructures = nativeStructures
    }
}

// MARK: - JGodotBuiltinClassMemberOffset
public struct JGodotBuiltinClassMemberOffset: Codable {
    public let buildConfiguration: String
    public let classes: [JGodotBuiltinClassMemberOffsetClass]

    enum CodingKeys: String, CodingKey {
        case buildConfiguration = "build_configuration"
        case classes
    }

    public init(buildConfiguration: String, classes: [JGodotBuiltinClassMemberOffsetClass]) {
        self.buildConfiguration = buildConfiguration
        self.classes = classes
    }
}

// MARK: - JGodotBuiltinClassMemberOffsetClass
public struct JGodotBuiltinClassMemberOffsetClass: Codable {
    public let name: JGodotTypeEnum
    public let members: [JGodotMember]

    public init(name: JGodotTypeEnum, members: [JGodotMember]) {
        self.name = name
        self.members = members
    }
}

// MARK: - JGodotMember
public struct JGodotMember: Codable {
    public let member: String
    public let offset: Int
    public let meta: JGodotMemberMeta

    public init(member: String, offset: Int, meta: JGodotMemberMeta) {
        self.member = member
        self.offset = offset
        self.meta = meta
    }
}

public enum JGodotMemberMeta: String, Codable {
    case basis = "Basis"
    case double = "double"
    case float = "float"
    case int32 = "int32"
    case vector2 = "Vector2"
    case vector2I = "Vector2i"
    case vector3 = "Vector3"
    case vector4 = "Vector4"
}

public enum JGodotTypeEnum: String, Codable {
    case aabb = "AABB"
    case basis = "Basis"
    case color = "Color"
    case int = "int"
    case plane = "Plane"
    case projection = "Projection"
    case quaternion = "Quaternion"
    case rect2 = "Rect2"
    case rect2I = "Rect2i"
    case transform2D = "Transform2D"
    case transform3D = "Transform3D"
    case vector2 = "Vector2"
    case vector2I = "Vector2i"
    case vector3 = "Vector3"
    case vector3I = "Vector3i"
    case vector4 = "Vector4"
    case vector4I = "Vector4i"
}

// MARK: - JGodotBuiltinClassSize
public struct JGodotBuiltinClassSize: Codable {
    public let buildConfiguration: String
    public let sizes: [JGodotSize]

    enum CodingKeys: String, CodingKey {
        case buildConfiguration = "build_configuration"
        case sizes
    }

    public init(buildConfiguration: String, sizes: [JGodotSize]) {
        self.buildConfiguration = buildConfiguration
        self.sizes = sizes
    }
}

// MARK: - JGodotSize
public struct JGodotSize: Codable {
    public let name: String
    public let size: Int

    public init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
}

// MARK: - JGodotBuiltinClass
public struct JGodotBuiltinClass: Codable {
    public let name: String
    public let isKeyed: Bool
    public let operators: [JGodotOperator]
    public let constructors: [JGodotConstructor]
    public let hasDestructor: Bool
    public let indexingReturnType: String?
    public let methods: [JGodotBuiltinClassMethod]?
    public let members: [JGodotArgument]?
    public let constants: [JGodotBuiltinClassConstant]?
    public let enums: [JGodotGlobalEnumElement]?
    public let brief_description: String?
    public let description: String?

    enum CodingKeys: String, CodingKey {
        case name
        case isKeyed = "is_keyed"
        case operators, constructors
        case hasDestructor = "has_destructor"
        case indexingReturnType = "indexing_return_type"
        case methods, members, constants, enums
        case brief_description
        case description
    }

    public init(name: String, isKeyed: Bool, brief_description: String, description: String, operators: [JGodotOperator], constructors: [JGodotConstructor], hasDestructor: Bool, indexingReturnType: String?, methods: [JGodotBuiltinClassMethod]?, members: [JGodotArgument]?, constants: [JGodotBuiltinClassConstant]?, enums: [JGodotGlobalEnumElement]?) {
        self.name = name
        self.description = description
        self.brief_description = brief_description
        self.isKeyed = isKeyed
        self.operators = operators
        self.constructors = constructors
        self.hasDestructor = hasDestructor
        self.indexingReturnType = indexingReturnType
        self.methods = methods
        self.members = members
        self.constants = constants
        self.enums = enums
    }
}

// MARK: - JGodotBuiltinClassConstant
public struct JGodotBuiltinClassConstant: Codable {
    public let name: String
    public let type: JGodotTypeEnum
    public let value: String
    public let description: String

    public init(name: String, type: JGodotTypeEnum, value: String, description: String) {
        self.name = name
        self.type = type
        self.value = value
        self.description = description
    }
}

// MARK: - JGodotConstructor
public struct JGodotConstructor: Codable {
    public let index: Int
    public let description: String?
    public let arguments: [JGodotArgument]?

    public init(index: Int, description: String, arguments: [JGodotArgument]?) {
        self.index = index
        self.arguments = arguments
        self.description = description
    }
}

// MARK: - JGodotBuiltinClassEnum
public struct JGodotBuiltinClassEnum: Codable {
    public let name: String
    public let values: [JGodotValueElement]

    public init(name: String, values: [JGodotValueElement]) {
        self.name = name
        self.values = values
    }
}

// MARK: - JGodotValueElement
public struct JGodotValueElement: Codable {
    public let name: String
    public let value: Int
    public let description: String
    
    public init(name: String, value: Int, description: String) {
        self.name = name
        self.value = value
        self.description = description
    }
}

// MARK: - JGodotBuiltinClassMethod
public struct JGodotBuiltinClassMethod: Codable {
    public let name: String
    public let returnType: String?
    public let isVararg, isConst, isStatic: Bool
    public let hash: Int
    public let description: String
    public let arguments: [JGodotArgument]?

    enum CodingKeys: String, CodingKey {
        case name
        case returnType = "return_type"
        case isVararg = "is_vararg"
        case isConst = "is_const"
        case isStatic = "is_static"
        case hash, arguments
        case description
    }

    public init(name: String, description: String, returnType: String?, isVararg: Bool, isConst: Bool, isStatic: Bool, hash: Int, arguments: [JGodotArgument]?) {
        self.name = name
        self.returnType = returnType
        self.isVararg = isVararg
        self.isConst = isConst
        self.isStatic = isStatic
        self.hash = hash
        self.arguments = arguments
        self.description = description
    }
}

// MARK: - JGodotArgument
public struct JGodotArgument: Codable {
    public let name, type: String
    public let description: String?
    public let defaultValue: String?
    public let meta: JGodotArgumentMeta?

    enum CodingKeys: String, CodingKey {
        case name, type
        case defaultValue = "default_value"
        case meta
        case description
    }

    public init(name: String, type: String, description: String? = nil, defaultValue: String?, meta: JGodotArgumentMeta?) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.meta = meta
        self.description = description
    }
}

public enum JGodotArgumentMeta: String, Codable {
    case double = "double"
    case float = "float"
    case int16 = "int16"
    case int32 = "int32"
    case int64 = "int64"
    case int8 = "int8"
    case uint16 = "uint16"
    case uint32 = "uint32"
    case uint64 = "uint64"
    case uint8 = "uint8"
}

// MARK: - JGodotOperator
public struct JGodotOperator: Codable {
    public let name: String
    public let description: String?
    public let rightType: String?
    public let returnType: String

    enum CodingKeys: String, CodingKey {
        case name
        case rightType = "right_type"
        case returnType = "return_type"
        case description
    }

    public init(name: String, description: String, rightType: String?, returnType: String) {
        self.name = name
        self.rightType = rightType
        self.returnType = returnType
        self.description = description
    }
}

// MARK: - JGodotExtensionAPIClass
public struct JGodotExtensionAPIClass: Codable {
    public let name: String
    public let isRefcounted, isInstantiable: Bool
    public let inherits: String?
    public let apiType: JGodotAPIType
    public let brief_description: String
    public let description: String
    public let enums: [JGodotGlobalEnumElement]?
    public let methods: [JGodotClassMethod]?
    public let properties: [JGodotProperty]?
    public let signals: [JGodotSignal]?
    public let constants: [JGodotValueElement]?

    enum CodingKeys: String, CodingKey {
        case name
        case isRefcounted = "is_refcounted"
        case isInstantiable = "is_instantiable"
        case inherits
        case apiType = "api_type"
        case brief_description
        case description
        case enums, methods, properties, signals, constants
    }

    public init(name: String, isRefcounted: Bool, isInstantiable: Bool, inherits: String?, apiType: JGodotAPIType, brief_description: String, description: String, enums: [JGodotGlobalEnumElement]?, methods: [JGodotClassMethod]?, properties: [JGodotProperty]?, signals: [JGodotSignal]?, constants: [JGodotValueElement]?) {
        self.name = name
        self.isRefcounted = isRefcounted
        self.isInstantiable = isInstantiable
        self.inherits = inherits
        self.apiType = apiType
        self.enums = enums
        self.methods = methods
        self.properties = properties
        self.signals = signals
        self.constants = constants
        self.brief_description = brief_description
        self.description = description
    }
}

public enum JGodotAPIType: String, Codable {
    case core = "core"
    case editor = "editor"
}

// MARK: - JGodotGlobalEnumElement
public struct JGodotGlobalEnumElement: Codable {
    public let name: String
    public let isBitfield: Bool?
    public let values: [JGodotValueElement]

    enum CodingKeys: String, CodingKey {
        case name
        case isBitfield = "is_bitfield"
        case values
    }

    public init(name: String, isBitfield: Bool, values: [JGodotValueElement]) {
        self.name = name
        self.isBitfield = isBitfield
        self.values = values
    }
}

// MARK: - JGodotClassMethod
public struct JGodotClassMethod: Codable {
    public let name: String
    public let isConst, isVararg, isStatic, isVirtual: Bool
    public let hash: Int?
    public let returnValue: JGodotReturnValue?
    public let description: String?
    public let arguments: [JGodotArgument]?

    enum CodingKeys: String, CodingKey {
        case name
        case isConst = "is_const"
        case isVararg = "is_vararg"
        case isStatic = "is_static"
        case isVirtual = "is_virtual"
        case hash
        case returnValue = "return_value"
        case arguments
        case description
    }

    public init(name: String, isConst: Bool, isVararg: Bool, isStatic: Bool, isVirtual: Bool, hash: Int?, description: String, returnValue: JGodotReturnValue?, arguments: [JGodotArgument]?) {
        self.name = name
        self.isConst = isConst
        self.isVararg = isVararg
        self.isStatic = isStatic
        self.isVirtual = isVirtual
        self.hash = hash
        self.returnValue = returnValue
        self.arguments = arguments
        self.description = description
    }
}

// MARK: - JGodotReturnValue
public struct JGodotReturnValue: Codable {
    public let type: String
    public let meta: JGodotArgumentMeta?

    public init(type: String, meta: JGodotArgumentMeta?) {
        self.type = type
        self.meta = meta
    }
}

// MARK: - JGodotProperty
public struct JGodotProperty: Codable {
    public let type, name: String
    public let setter: String?
    public let getter: String
    public let description: String?
    public let index: Int?

    public init(type: String, name: String, setter: String?, getter: String, description: String, index: Int?) {
        self.type = type
        self.name = name
        self.setter = setter
        self.getter = getter
        self.index = index
        self.description = description
    }
}

// MARK: - JGodotSignal
public struct JGodotSignal: Codable {
    public let name: String
    public let arguments: [JGodotArgument]?
    public let description: String

    public init(name: String, description: String, arguments: [JGodotArgument]?) {
        self.name = name
        self.arguments = arguments
        self.description = description
    }
}

// MARK: - JGodotHeader
public struct JGodotHeader: Codable {
    public let versionMajor, versionMinor, versionPatch: Int
    public let versionStatus, versionBuild, versionFullName: String

    enum CodingKeys: String, CodingKey {
        case versionMajor = "version_major"
        case versionMinor = "version_minor"
        case versionPatch = "version_patch"
        case versionStatus = "version_status"
        case versionBuild = "version_build"
        case versionFullName = "version_full_name"
    }

    public init(versionMajor: Int, versionMinor: Int, versionPatch: Int, versionStatus: String, versionBuild: String, versionFullName: String) {
        self.versionMajor = versionMajor
        self.versionMinor = versionMinor
        self.versionPatch = versionPatch
        self.versionStatus = versionStatus
        self.versionBuild = versionBuild
        self.versionFullName = versionFullName
    }
}

// MARK: - JGodotNativeStructure
public struct JGodotNativeStructure: Codable {
    public let name, format: String

    public init(name: String, format: String) {
        self.name = name
        self.format = format
    }
}

// MARK: - JGodotUtilityFunction
public struct JGodotUtilityFunction: Codable {
    public let name: String
    public let returnType: String?
    public let category: JGodotCategory
    public let isVararg: Bool
    public let hash: Int
    public let description: String?
    public let arguments: [JGodotArgument]?

    enum CodingKeys: String, CodingKey {
        case name
        case returnType = "return_type"
        case category
        case isVararg = "is_vararg"
        case description
        case hash, arguments
    }

    public init(name: String, returnType: String?, category: JGodotCategory, isVararg: Bool, hash: Int, description: String, arguments: [JGodotArgument]?) {
        self.name = name
        self.returnType = returnType
        self.category = category
        self.isVararg = isVararg
        self.hash = hash
        self.arguments = arguments
        self.description = description
    }
}

public enum JGodotCategory: String, Codable {
    case general = "general"
    case math = "math"
    case random = "random"
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {

    public let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
