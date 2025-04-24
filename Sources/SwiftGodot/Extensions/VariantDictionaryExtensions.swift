//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/23/23.
//

@available(*, deprecated, renamed: "VariantDictionary", message: "GDictionary was renamed to `VariantDictionary` to better communicate its semantics")
public typealias GDictionary = VariantArray

extension VariantDictionary: CustomDebugStringConvertible, CustomStringConvertible {
    
    /// Return the key typing information suitable for Swift metatype magic.
    @usableFromInline
    var keyTyping: ContainerTypingParameter {
        let rawValue = getTypedKeyBuiltin()
        guard let gtype = Variant.GType(rawValue: rawValue) else {
            fatalError("Unknown variant type rawValue: \(rawValue)")
        }
        
        switch gtype {
        case .object:
            let className = getTypedKeyClassName().asciiDescription
            guard let metatype = typeOfClass(named: className) else {
                GD.printErr("Unknown class name: \(className).")
                return .builtin(.nil)
            }
            
            return .object(metatype)
        default:
            return .builtin(gtype)
        }
    }
    
    /// Return the value typing information suitable for Swift metatype magic.
    @usableFromInline
    var valueTyping:ContainerTypingParameter {
        let rawValue = getTypedValueBuiltin()
        guard let gtype = Variant.GType(rawValue: rawValue) else {
            fatalError("Unknown variant type rawValue: \(rawValue)")
        }
        
        switch gtype {
        case .object:
            let className = getTypedValueClassName().asciiDescription
            guard let metatype = typeOfClass(named: className) else {
                GD.printErr("Unknown class name: \(className).")
                return .builtin(.nil)
            }
            
            return .object(metatype)
        default:
            return .builtin(gtype)
        }
    }
    
    public subscript(key: some VariantConvertible) -> FastVariant? {
        get {
            let key = key.toFastVariant()
            
            switch key {
            case .some(let key):
                var keyContent = key.content
                if GodotInterfaceForDictionary.keyed_checker(&content, &keyContent) != 0 {
                    var result = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_getter(&content, &keyContent, &result)
                    return FastVariant(takingOver: result)
                } else {
                    return nil
                }
            case .none:
                var keyContent = VariantContent.zero
                if GodotInterfaceForDictionary.keyed_checker(&content, &keyContent) != 0 {
                    var result = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_getter(&content, &keyContent, &result)
                    return FastVariant(takingOver: result)
                } else {
                    return nil
                }
            }
            var keyContent = key?.content ?? .zero
                        
        }
    
        consuming set {
            let key = key.toFastVariant()
            switch newValue {
            case .some(let newValue):
                switch key {
                case .some(let key):
                    var newValueContent = newValue.content
                    var keyContent = key.content
                    
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                case .none:
                    var newValueContent = newValue.content
                    var keyContent = VariantContent.zero
                    
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                }
            case .none:
                switch key {
                case .some(let key):
                    var keyContent = key.content
                    
                    var nilContent = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &nilContent)
                case .none:
                    var keyContent = VariantContent.zero
                    var nilContent = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &nilContent)
                }
            }
        }
    }

    
    /// Convenience subscript that uses a String as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    public subscript(key: String) -> Variant? {
        get {
            return self[Variant (key)]
        }
        set {
            self[Variant(key)] = newValue
        }
    }
    
    /// Convenience subscript that uses a StringName as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    public subscript (key: StringName) -> Variant? {
        get {
            return self[Variant(key)]
        }
        set {
            self[Variant(key)] = newValue
        }
    }

    /// Renders the dictionary using the `Variant`'s `description` method.
    public var debugDescription: String {
        Variant(self).description
    }

    /// Renders the dictionary using the `Variant`'s `description` method.
    public var description: String {
        Variant(self).description
    }
}
