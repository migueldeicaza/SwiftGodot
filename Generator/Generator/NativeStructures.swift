//
//  Generates the native structure definitions from the JSon file
//
//
//  Created by Miguel de Icaza on 7/2/24.
//

import ExtensionApi

private enum NativeMapType {
    case straight
    case enumeration
    case variant
}

extension Generator {
    // The types exposed here are not the same as the ones we process elsewhere
    // the additional boolean value represents whether this needs an enum wrapper
    // since our enums are 64 bit values, and the way that they are encoded in these
    // native structures is 32 bit values
private func mapNativeType (_ name: Substring) -> (String, NativeMapType, ClassTrait?)? {
        switch name {
        case "float":
            return ("Float", .straight, nil)
        case "uint64_t":
            return ("UInt64", .straight, nil)
        case "int32_t":
            return ("Int32", .straight, nil)
        case "uint16_t":
            return ("UInt16", .straight, nil)
        case "real_t":
            return ("Float", .straight, nil)
        case "int":
            return ("Int32", .straight, nil)
        case "Rect2":
            return ("Rect2", .straight, nil)
        case "Vector3":
            return ("Vector3", .straight, nil)
        case "Vector2":
            return ("Vector2", .straight, nil)
        case "TextServer::Direction":
            return ("TextServer.Direction", .enumeration, .full)
        case "ObjectID":
            return ("ObjectID", .straight, nil)
        case "Object":
            return ("Object", .variant, nil)
        case "RID":
            return ("RID", .variant, nil)
        case "StringName":
            return ("StringName", .variant, nil)
        case "uint8_t":
            return ("UInt8", .straight, nil)
        case "PhysicsServer3DExtensionMotionCollision":
            return ("PhysicsServer3DExtensionMotionCollision", .straight, nil)
        default:
            print ("Failed with \(name)")
            return nil
        }
    }
    func generateNativeStructures (_ p: Printer, values: [JGodotNativeStructure]) {
        for structure in values {
            var generate = true
            var ofields: [(String,(String, NativeMapType, ClassTrait?))] = []
            var requiredTraits = Set<ClassTrait>()

            for fields in structure.format.split (separator: ";") {
                if fields.contains ("*") {
                    // TODO: need to figure out how to surface the setter for
                    // things like Object* which is a class that contains a ContentType
                    generate = false
                    continue
                }
                if fields.contains ("[") {
                    // Need support for inlined arrays
                    generate = false
                }
                let pair = fields.split (separator: " ")
                guard pair.count >= 2 else {
                    print ("Missing values: \(fields)")
                    generate = false
                    continue
                }
                guard let typeInfo = mapNativeType (pair [0]) else {
                    print ("Unhandled type in nativeStrucures \(pair [0])")
                    generate = false
                    continue
                }
                let name = String(pair [1])
                ofields.append ((snakeToCamel(name), typeInfo))
                if let trait = typeInfo.2 {
                    requiredTraits.insert(trait)
                }
            }

            if !generate {
                continue
            }

            if let guardTrait = requiredTraits.max(by: { traitPriority($0) < traitPriority($1) }), guardTrait != .core {
                p("#if \(macroName(for: guardTrait))")
            }

            p ("public struct \(structure.name)") {
                for field in ofields {
                    let typeInfo = field.1
                    switch typeInfo.1 {
                    case .enumeration:
                        p ("var _\(field.0): Int32")
                        p ("public var \(field.0): \(field.1.0)") {
                            p ("get") {
                                p ("return \(field.1.0) (rawValue: Int64 (_\(field.0)))!")
                            }
                            p ("set") {
                                p ("_\(field.0) = Int32 (bitPattern: UInt32(UInt64 (newValue.rawValue) & 0xffffffff))")
                            }
                        }
                    case .straight:
                        p ("public var \(escapeSwift(field.0)): \(field.1.0)")

                    case .variant:
                        let name: String
                        let isPointer: Bool

                        // Currently the pointer code is disabled while I figure out the
                        // semantics of Object* in the setter
                        if field.0.contains ("*") {
                            name = String(field.0.dropFirst())
                            isPointer = true
                        } else {
                            name = field.0
                            isPointer = false
                        }
                        if isPointer {
                            p ("var _\(name): UnsafeMutablePointer<\(field.1.0).ContentType>?")
                        } else {
                            p ("var _\(name): \(field.1.0).ContentType")
                        }

                        p ("public var \(escapeSwift(name)): \(field.1.0)\(isPointer ? "?" : "")") {
                            p ("get") {
                                if isPointer {
                                    p ("if let x = _\(name) { return \(field.1.0) (content: x.pointee) } else { return nil }")
                                } else {
                                    p ("return \(field.1.0) (content: _\(field.0))")
                                }
                            }
                            p ("set") {
                                p ("_\(name) = newValue.content")
                            }
                        }
                    }
                }
            }
            if let guardTrait = requiredTraits.max(by: { traitPriority($0) < traitPriority($1) }), guardTrait != .core {
                p("#endif // \(macroName(for: guardTrait))")
            }
        }
    }
}
