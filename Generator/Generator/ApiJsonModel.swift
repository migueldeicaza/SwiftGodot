//
//  ApiJsonModel.swift
//  Generator
//
//  Created by Miguel de Icaza on 3/24/23.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jGodotExtensionAPI = try JGodotExtensionAPI(json)

import Foundation

// MARK: - JGodotExtensionAPI
struct JGodotExtensionAPI: Codable {
    let header: JGodotHeader
    let builtinClassSizes: [JGodotBuiltinClassSize]
    let builtinClassMemberOffsets: [JGodotBuiltinClassMemberOffset]
    let globalConstants: [JSONAny]
    let globalEnums: [JGodotGlobalEnumElement]
    let utilityFunctions: [JGodotUtilityFunction]
    let builtinClasses: [JGodotBuiltinClass]
    let classes: [JGodotExtensionAPIClass]
    let singletons: [JGodotSingleton]
    let nativeStructures: [JGodotNativeStructure]

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
}

// MARK: JGodotExtensionAPI convenience initializers and mutators

extension JGodotExtensionAPI {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotExtensionAPI.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        header: JGodotHeader? = nil,
        builtinClassSizes: [JGodotBuiltinClassSize]? = nil,
        builtinClassMemberOffsets: [JGodotBuiltinClassMemberOffset]? = nil,
        globalConstants: [JSONAny]? = nil,
        globalEnums: [JGodotGlobalEnumElement]? = nil,
        utilityFunctions: [JGodotUtilityFunction]? = nil,
        builtinClasses: [JGodotBuiltinClass]? = nil,
        classes: [JGodotExtensionAPIClass]? = nil,
        singletons: [JGodotSingleton]? = nil,
        nativeStructures: [JGodotNativeStructure]? = nil
    ) -> JGodotExtensionAPI {
        return JGodotExtensionAPI(
            header: header ?? self.header,
            builtinClassSizes: builtinClassSizes ?? self.builtinClassSizes,
            builtinClassMemberOffsets: builtinClassMemberOffsets ?? self.builtinClassMemberOffsets,
            globalConstants: globalConstants ?? self.globalConstants,
            globalEnums: globalEnums ?? self.globalEnums,
            utilityFunctions: utilityFunctions ?? self.utilityFunctions,
            builtinClasses: builtinClasses ?? self.builtinClasses,
            classes: classes ?? self.classes,
            singletons: singletons ?? self.singletons,
            nativeStructures: nativeStructures ?? self.nativeStructures
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClassMemberOffset
struct JGodotBuiltinClassMemberOffset: Codable {
    let buildConfiguration: String
    let classes: [JGodotBuiltinClassMemberOffsetClass]

    enum CodingKeys: String, CodingKey {
        case buildConfiguration = "build_configuration"
        case classes
    }
}

// MARK: JGodotBuiltinClassMemberOffset convenience initializers and mutators

extension JGodotBuiltinClassMemberOffset {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassMemberOffset.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        buildConfiguration: String? = nil,
        classes: [JGodotBuiltinClassMemberOffsetClass]? = nil
    ) -> JGodotBuiltinClassMemberOffset {
        return JGodotBuiltinClassMemberOffset(
            buildConfiguration: buildConfiguration ?? self.buildConfiguration,
            classes: classes ?? self.classes
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClassMemberOffsetClass
struct JGodotBuiltinClassMemberOffsetClass: Codable {
    let name: JGodotTypeEnum
    let members: [JGodotMember]
}

// MARK: JGodotBuiltinClassMemberOffsetClass convenience initializers and mutators

extension JGodotBuiltinClassMemberOffsetClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassMemberOffsetClass.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: JGodotTypeEnum? = nil,
        members: [JGodotMember]? = nil
    ) -> JGodotBuiltinClassMemberOffsetClass {
        return JGodotBuiltinClassMemberOffsetClass(
            name: name ?? self.name,
            members: members ?? self.members
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotMember
struct JGodotMember: Codable {
    let member: String
    let offset: Int
    let meta: JGodotMemberMeta
}

// MARK: JGodotMember convenience initializers and mutators

extension JGodotMember {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotMember.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        member: String? = nil,
        offset: Int? = nil,
        meta: JGodotMemberMeta? = nil
    ) -> JGodotMember {
        return JGodotMember(
            member: member ?? self.member,
            offset: offset ?? self.offset,
            meta: meta ?? self.meta
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum JGodotMemberMeta: String, Codable {
    case basis = "Basis"
    case double = "double"
    case float = "float"
    case int32 = "int32"
    case vector2 = "Vector2"
    case vector2I = "Vector2i"
    case vector3 = "Vector3"
    case vector4 = "Vector4"
}

enum JGodotTypeEnum: String, Codable {
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
struct JGodotBuiltinClassSize: Codable {
    let buildConfiguration: String
    let sizes: [JGodotSize]

    enum CodingKeys: String, CodingKey {
        case buildConfiguration = "build_configuration"
        case sizes
    }
}

// MARK: JGodotBuiltinClassSize convenience initializers and mutators

extension JGodotBuiltinClassSize {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassSize.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        buildConfiguration: String? = nil,
        sizes: [JGodotSize]? = nil
    ) -> JGodotBuiltinClassSize {
        return JGodotBuiltinClassSize(
            buildConfiguration: buildConfiguration ?? self.buildConfiguration,
            sizes: sizes ?? self.sizes
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotSize
struct JGodotSize: Codable {
    let name: String
    let size: Int
}

// MARK: JGodotSize convenience initializers and mutators

extension JGodotSize {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotSize.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        size: Int? = nil
    ) -> JGodotSize {
        return JGodotSize(
            name: name ?? self.name,
            size: size ?? self.size
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClass
struct JGodotBuiltinClass: Codable {
    let name: String
    let isKeyed: Bool
    let operators: [JGodotOperator]
    let constructors: [JGodotConstructor]
    let hasDestructor: Bool
    let indexingReturnType: String?
    let methods: [JGodotBuiltinClassMethod]?
    let members: [JGodotSingleton]?
    let constants: [JGodotBuiltinClassConstant]?
    let enums: [JGodotBuiltinClassEnum]?

    enum CodingKeys: String, CodingKey {
        case name
        case isKeyed = "is_keyed"
        case operators, constructors
        case hasDestructor = "has_destructor"
        case indexingReturnType = "indexing_return_type"
        case methods, members, constants, enums
    }
}

// MARK: JGodotBuiltinClass convenience initializers and mutators

extension JGodotBuiltinClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClass.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        isKeyed: Bool? = nil,
        operators: [JGodotOperator]? = nil,
        constructors: [JGodotConstructor]? = nil,
        hasDestructor: Bool? = nil,
        indexingReturnType: String?? = nil,
        methods: [JGodotBuiltinClassMethod]?? = nil,
        members: [JGodotSingleton]?? = nil,
        constants: [JGodotBuiltinClassConstant]?? = nil,
        enums: [JGodotBuiltinClassEnum]?? = nil
    ) -> JGodotBuiltinClass {
        return JGodotBuiltinClass(
            name: name ?? self.name,
            isKeyed: isKeyed ?? self.isKeyed,
            operators: operators ?? self.operators,
            constructors: constructors ?? self.constructors,
            hasDestructor: hasDestructor ?? self.hasDestructor,
            indexingReturnType: indexingReturnType ?? self.indexingReturnType,
            methods: methods ?? self.methods,
            members: members ?? self.members,
            constants: constants ?? self.constants,
            enums: enums ?? self.enums
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClassConstant
struct JGodotBuiltinClassConstant: Codable {
    let name: String
    let type: JGodotTypeEnum
    let value: String
}

// MARK: JGodotBuiltinClassConstant convenience initializers and mutators

extension JGodotBuiltinClassConstant {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassConstant.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        type: JGodotTypeEnum? = nil,
        value: String? = nil
    ) -> JGodotBuiltinClassConstant {
        return JGodotBuiltinClassConstant(
            name: name ?? self.name,
            type: type ?? self.type,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotConstructor
struct JGodotConstructor: Codable {
    let index: Int
    let arguments: [JGodotSingleton]?
}

// MARK: JGodotConstructor convenience initializers and mutators

extension JGodotConstructor {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotConstructor.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        index: Int? = nil,
        arguments: [JGodotSingleton]?? = nil
    ) -> JGodotConstructor {
        return JGodotConstructor(
            index: index ?? self.index,
            arguments: arguments ?? self.arguments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotSingleton
struct JGodotSingleton: Codable, Equatable {
    let name, type: String
}

// MARK: JGodotSingleton convenience initializers and mutators

extension JGodotSingleton {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotSingleton.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        type: String? = nil
    ) -> JGodotSingleton {
        return JGodotSingleton(
            name: name ?? self.name,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClassEnum
struct JGodotBuiltinClassEnum: Codable {
    let name: String
    let values: [JGodotValueElement]
}

// MARK: JGodotBuiltinClassEnum convenience initializers and mutators

extension JGodotBuiltinClassEnum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassEnum.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        values: [JGodotValueElement]? = nil
    ) -> JGodotBuiltinClassEnum {
        return JGodotBuiltinClassEnum(
            name: name ?? self.name,
            values: values ?? self.values
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotValueElement
struct JGodotValueElement: Codable {
    let name: String
    let value: Int
}

// MARK: JGodotValueElement convenience initializers and mutators

extension JGodotValueElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotValueElement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        value: Int? = nil
    ) -> JGodotValueElement {
        return JGodotValueElement(
            name: name ?? self.name,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotBuiltinClassMethod
struct JGodotBuiltinClassMethod: Codable {
    let name: String
    let returnType: String?
    let isVararg, isConst, isStatic: Bool
    let hash: Int
    let arguments: [JGodotArgument]?

    enum CodingKeys: String, CodingKey {
        case name
        case returnType = "return_type"
        case isVararg = "is_vararg"
        case isConst = "is_const"
        case isStatic = "is_static"
        case hash, arguments
    }
}

// MARK: JGodotBuiltinClassMethod convenience initializers and mutators

extension JGodotBuiltinClassMethod {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotBuiltinClassMethod.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        returnType: String?? = nil,
        isVararg: Bool? = nil,
        isConst: Bool? = nil,
        isStatic: Bool? = nil,
        hash: Int? = nil,
        arguments: [JGodotArgument]?? = nil
    ) -> JGodotBuiltinClassMethod {
        return JGodotBuiltinClassMethod(
            name: name ?? self.name,
            returnType: returnType ?? self.returnType,
            isVararg: isVararg ?? self.isVararg,
            isConst: isConst ?? self.isConst,
            isStatic: isStatic ?? self.isStatic,
            hash: hash ?? self.hash,
            arguments: arguments ?? self.arguments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotArgument
struct JGodotArgument: Codable {
    let name, type: String
    let defaultValue: String?
    let meta: JGodotArgumentMeta?

    enum CodingKeys: String, CodingKey {
        case name, type
        case defaultValue = "default_value"
        case meta
    }
}

// MARK: JGodotArgument convenience initializers and mutators

extension JGodotArgument {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotArgument.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        type: String? = nil,
        defaultValue: String?? = nil,
        meta: JGodotArgumentMeta?? = nil
    ) -> JGodotArgument {
        return JGodotArgument(
            name: name ?? self.name,
            type: type ?? self.type,
            defaultValue: defaultValue ?? self.defaultValue,
            meta: meta ?? self.meta
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum JGodotArgumentMeta: String, Codable {
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
struct JGodotOperator: Codable {
    let name: JGodotOperatorName
    let rightType: String?
    let returnType: String

    enum CodingKeys: String, CodingKey {
        case name
        case rightType = "right_type"
        case returnType = "return_type"
    }
}

// MARK: JGodotOperator convenience initializers and mutators

extension JGodotOperator {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotOperator.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: JGodotOperatorName? = nil,
        rightType: String?? = nil,
        returnType: String? = nil
    ) -> JGodotOperator {
        return JGodotOperator(
            name: name ?? self.name,
            rightType: rightType ?? self.rightType,
            returnType: returnType ?? self.returnType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum JGodotOperatorName: String, Codable {
    case ambitious = "*"
    case and = "and"
    case braggadocious = ">>"
    case cunning = "/"
    case empty = "=="
    case fluffy = ">"
    case frisky = "**"
    case hilarious = "-"
    case indecent = "+"
    case indigo = ">="
    case magenta = "%"
    case mischievous = "<<"
    case name = "!="
    case nameIn = "in"
    case nameUnary = "unary+"
    case not = "not"
    case or = "or"
    case purple = "<"
    case sticky = "<="
    case tentacled = "~"
    case the1 = "&"
    case the2 = "|"
    case the3 = "^"
    case unary = "unary-"
    case xor = "xor"
}

// MARK: - JGodotExtensionAPIClass
struct JGodotExtensionAPIClass: Codable {
    let name: String
    let isRefcounted, isInstantiable: Bool
    let inherits: String?
    let apiType: JGodotAPIType
    let enums: [JGodotGlobalEnumElement]?
    let methods: [JGodotClassMethod]?
    let properties: [JGodotProperty]?
    let signals: [JGodotSignal]?
    let constants: [JGodotValueElement]?

    enum CodingKeys: String, CodingKey {
        case name
        case isRefcounted = "is_refcounted"
        case isInstantiable = "is_instantiable"
        case inherits
        case apiType = "api_type"
        case enums, methods, properties, signals, constants
    }
}

// MARK: JGodotExtensionAPIClass convenience initializers and mutators

extension JGodotExtensionAPIClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotExtensionAPIClass.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        isRefcounted: Bool? = nil,
        isInstantiable: Bool? = nil,
        inherits: String?? = nil,
        apiType: JGodotAPIType? = nil,
        enums: [JGodotGlobalEnumElement]?? = nil,
        methods: [JGodotClassMethod]?? = nil,
        properties: [JGodotProperty]?? = nil,
        signals: [JGodotSignal]?? = nil,
        constants: [JGodotValueElement]?? = nil
    ) -> JGodotExtensionAPIClass {
        return JGodotExtensionAPIClass(
            name: name ?? self.name,
            isRefcounted: isRefcounted ?? self.isRefcounted,
            isInstantiable: isInstantiable ?? self.isInstantiable,
            inherits: inherits ?? self.inherits,
            apiType: apiType ?? self.apiType,
            enums: enums ?? self.enums,
            methods: methods ?? self.methods,
            properties: properties ?? self.properties,
            signals: signals ?? self.signals,
            constants: constants ?? self.constants
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum JGodotAPIType: String, Codable {
    case core = "core"
    case editor = "editor"
}

// MARK: - JGodotGlobalEnumElement
struct JGodotGlobalEnumElement: Codable {
    let name: String
    let isBitfield: Bool
    let values: [JGodotValueElement]

    enum CodingKeys: String, CodingKey {
        case name
        case isBitfield = "is_bitfield"
        case values
    }
}

// MARK: JGodotGlobalEnumElement convenience initializers and mutators

extension JGodotGlobalEnumElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotGlobalEnumElement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        isBitfield: Bool? = nil,
        values: [JGodotValueElement]? = nil
    ) -> JGodotGlobalEnumElement {
        return JGodotGlobalEnumElement(
            name: name ?? self.name,
            isBitfield: isBitfield ?? self.isBitfield,
            values: values ?? self.values
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotClassMethod
struct JGodotClassMethod: Codable {
    let name: String
    let isConst, isVararg, isStatic, isVirtual: Bool
    let hash: Int?
    let returnValue: JGodotReturnValue?
    let arguments: [JGodotArgument]?

    enum CodingKeys: String, CodingKey {
        case name
        case isConst = "is_const"
        case isVararg = "is_vararg"
        case isStatic = "is_static"
        case isVirtual = "is_virtual"
        case hash
        case returnValue = "return_value"
        case arguments
    }
}

// MARK: JGodotClassMethod convenience initializers and mutators

extension JGodotClassMethod {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotClassMethod.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        isConst: Bool? = nil,
        isVararg: Bool? = nil,
        isStatic: Bool? = nil,
        isVirtual: Bool? = nil,
        hash: Int?? = nil,
        returnValue: JGodotReturnValue?? = nil,
        arguments: [JGodotArgument]?? = nil
    ) -> JGodotClassMethod {
        return JGodotClassMethod(
            name: name ?? self.name,
            isConst: isConst ?? self.isConst,
            isVararg: isVararg ?? self.isVararg,
            isStatic: isStatic ?? self.isStatic,
            isVirtual: isVirtual ?? self.isVirtual,
            hash: hash ?? self.hash,
            returnValue: returnValue ?? self.returnValue,
            arguments: arguments ?? self.arguments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotReturnValue
struct JGodotReturnValue: Codable {
    let type: String
    let meta: JGodotArgumentMeta?
}

// MARK: JGodotReturnValue convenience initializers and mutators

extension JGodotReturnValue {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotReturnValue.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        type: String? = nil,
        meta: JGodotArgumentMeta?? = nil
    ) -> JGodotReturnValue {
        return JGodotReturnValue(
            type: type ?? self.type,
            meta: meta ?? self.meta
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotProperty
struct JGodotProperty: Codable {
    let type, name: String
    let setter: String?
    let getter: String
    let index: Int?
}

// MARK: JGodotProperty convenience initializers and mutators

extension JGodotProperty {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotProperty.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        type: String? = nil,
        name: String? = nil,
        setter: String?? = nil,
        getter: String? = nil,
        index: Int?? = nil
    ) -> JGodotProperty {
        return JGodotProperty(
            type: type ?? self.type,
            name: name ?? self.name,
            setter: setter ?? self.setter,
            getter: getter ?? self.getter,
            index: index ?? self.index
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotSignal
struct JGodotSignal: Codable {
    let name: String
    let arguments: [JGodotSingleton]?
}

// MARK: JGodotSignal convenience initializers and mutators

extension JGodotSignal {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotSignal.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        arguments: [JGodotSingleton]?? = nil
    ) -> JGodotSignal {
        return JGodotSignal(
            name: name ?? self.name,
            arguments: arguments ?? self.arguments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotHeader
struct JGodotHeader: Codable {
    let versionMajor, versionMinor, versionPatch: Int
    let versionStatus, versionBuild, versionFullName: String

    enum CodingKeys: String, CodingKey {
        case versionMajor = "version_major"
        case versionMinor = "version_minor"
        case versionPatch = "version_patch"
        case versionStatus = "version_status"
        case versionBuild = "version_build"
        case versionFullName = "version_full_name"
    }
}

// MARK: JGodotHeader convenience initializers and mutators

extension JGodotHeader {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotHeader.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        versionMajor: Int? = nil,
        versionMinor: Int? = nil,
        versionPatch: Int? = nil,
        versionStatus: String? = nil,
        versionBuild: String? = nil,
        versionFullName: String? = nil
    ) -> JGodotHeader {
        return JGodotHeader(
            versionMajor: versionMajor ?? self.versionMajor,
            versionMinor: versionMinor ?? self.versionMinor,
            versionPatch: versionPatch ?? self.versionPatch,
            versionStatus: versionStatus ?? self.versionStatus,
            versionBuild: versionBuild ?? self.versionBuild,
            versionFullName: versionFullName ?? self.versionFullName
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotNativeStructure
struct JGodotNativeStructure: Codable {
    let name, format: String
}

// MARK: JGodotNativeStructure convenience initializers and mutators

extension JGodotNativeStructure {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotNativeStructure.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        format: String? = nil
    ) -> JGodotNativeStructure {
        return JGodotNativeStructure(
            name: name ?? self.name,
            format: format ?? self.format
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - JGodotUtilityFunction
struct JGodotUtilityFunction: Codable {
    let name: String
    let returnType: JGodotReturnType?
    let category: JGodotCategory
    let isVararg: Bool
    let hash: Int
    let arguments: [JGodotSingleton]?

    enum CodingKeys: String, CodingKey {
        case name
        case returnType = "return_type"
        case category
        case isVararg = "is_vararg"
        case hash, arguments
    }
}

// MARK: JGodotUtilityFunction convenience initializers and mutators

extension JGodotUtilityFunction {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(JGodotUtilityFunction.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        returnType: JGodotReturnType?? = nil,
        category: JGodotCategory? = nil,
        isVararg: Bool? = nil,
        hash: Int? = nil,
        arguments: [JGodotSingleton]?? = nil
    ) -> JGodotUtilityFunction {
        return JGodotUtilityFunction(
            name: name ?? self.name,
            returnType: returnType ?? self.returnType,
            category: category ?? self.category,
            isVararg: isVararg ?? self.isVararg,
            hash: hash ?? self.hash,
            arguments: arguments ?? self.arguments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum JGodotCategory: String, Codable {
    case general = "general"
    case math = "math"
    case random = "random"
}

enum JGodotReturnType: String, Codable {
    case bool = "bool"
    case float = "float"
    case int = "int"
    case object = "Object"
    case packedByteArray = "PackedByteArray"
    case packedInt64Array = "PackedInt64Array"
    case rid = "RID"
    case string = "String"
    case variant = "Variant"
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
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

class JSONAny: Codable {

    let value: Any

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
