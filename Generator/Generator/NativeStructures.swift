//
//  Generates the native structure definitions from the JSon file
//
//
//  Created by Miguel de Icaza on 7/2/24.
//

import Foundation
import ExtensionApi

enum NativeMapType {
    case straight
    case enumeration
    case variant
}

// The types exposed here are not the same as the ones we process elsewhere
// the additional boolean value represents whether this needs an enum wrapper
// since our enums are 64 bit values, and the way that they are encoded in these
// native structures is 32 bit values
func mapNativeType (_ name: Substring) -> (String,NativeMapType)? {
    switch name {
    case "float":
        return ("Float", .straight)
    case "uint64_t":
        return ("UInt64", .straight)
    case "int32_t":
        return ("Int32", .straight)
    case "uint16_t":
        return ("UInt16", .straight)
    case "real_t":
        return ("Float", .straight)
    case "int":
        return ("Int32", .straight)
    case "Rect2":
        return ("Rect2", .straight)
    case "Vector3":
        return ("Vector3", .straight)
    case "Vector2":
        return ("Vector2", .straight)
    case "TextServer::Direction":
        return ("TextServer.Direction", .enumeration)
    case "ObjectID":
        return ("ObjectID", .straight)
    case "Object":
        return ("Object", .variant)
    case "RID":
        return ("RID", .variant)
    case "StringName":
        return ("StringName", .variant)
    case "uint8_t":
        return ("UInt8", .straight)
    case "PhysicsServer3DExtensionMotionCollision":
        return ("PhysicsServer3DExtensionMotionCollision", .straight)
    default:
        print ("Failed with \(name)")
        return nil
    }
}
func generateNativeStructures (_ p: Printer, values: [JGodotNativeStructure]) {
    for structure in values {
        var generate = true
        var ofields: [(String,(String, NativeMapType))] = []
        
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
        }

        if !generate {
            continue
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
    }
}
