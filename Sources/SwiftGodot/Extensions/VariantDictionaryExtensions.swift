//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/23/23.
//

@available(*, deprecated, renamed: "VariantDictionary", message: "GDictionary was renamed to `VariantDictionary` to better communicate its semantics")
public typealias GDictionary = VariantDictionary

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
    
    /// Subscript operator using arbitary ``VariantConvertible?`` type as a key.
    /// Works with ``FastVariant?``
    public subscript(key: (some VariantConvertible)?) -> FastVariant? {
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
        }
    
        consuming set {
            let key = key.toFastVariant()
            switch newValue {
            case .some(let newValue):
                var newValueContent = newValue.content
                switch key {
                case .some(let key):
                    var keyContent = key.content
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                case .none:
                    var keyContent = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                }
            case .none:
                var newValueContent = VariantContent.zero
                switch key {
                case .some(let key):
                    var keyContent = key.content
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                case .none:
                    var keyContent = VariantContent.zero
                    GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
                }
            }
        }
    }
    
    /// Removes the dictionary entry by key, if it exists. Returns `true` if the given `key` existed in the dictionary, otherwise `false`.
    ///
    /// > Note: Do not erase entries while iterating over the dictionary. You can iterate over the ``keys()`` array instead.
    ///
    public final func erase(fastKey: borrowing FastVariant?) -> Bool {
        var result: Bool = Bool()
        switch fastKey {
        case .some(let variant):
            let keyContent = variant.content
            withUnsafePointer(to: keyContent) { pArg0 in
                withUnsafePointer(to: UnsafeRawPointersN1(pArg0)) { pArgs in
                    pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 1) { pArgs in
                        GodotInterfaceForDictionary.method_erase(&content, pArgs, &result, 1)
                    }
                }
            }
        case .none:
            let keyContent = VariantContent.zero
            withUnsafePointer(to: keyContent) { pArg0 in
                withUnsafePointer(to: UnsafeRawPointersN1(pArg0)) { pArgs in
                    pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 1) { pArgs in
                        GodotInterfaceForDictionary.method_erase(&content, pArgs, &result, 1)
                    }
                }
            }
        }
        
        return result
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
