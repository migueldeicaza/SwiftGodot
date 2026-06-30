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
    
    /// Subscript operator using an arbitrary ``VariantConvertible?`` type as a key.
    public subscript(key: (some VariantConvertible)?) -> Variant? {
        get {
            var keyContent = key.toVariant().makeContent()
            defer { gi.variant_destroy(&keyContent) }

            if GodotInterfaceForDictionary.keyed_checker(&content, &keyContent) != 0 {
                var result = VariantContent.zero
                GodotInterfaceForDictionary.keyed_getter(&content, &keyContent, &result)
                return Variant(takingOver: result)
            } else {
                return nil
            }
        }

        set {
            var keyContent = key.toVariant().makeContent()
            defer { gi.variant_destroy(&keyContent) }
            var newValueContent = newValue.makeContent()
            defer { gi.variant_destroy(&newValueContent) }
            GodotInterfaceForDictionary.keyed_setter(&content, &keyContent, &newValueContent)
        }
    }

    /// Removes the dictionary entry by key, if it exists. Returns `true` if the given `key` existed in the dictionary, otherwise `false`.
    ///
    /// > Note: Do not erase entries while iterating over the dictionary. You can iterate over the ``keys()`` array instead.
    ///
    public final func erase(variantKey: Variant?) -> Bool {
        var result: Bool = Bool()
        var keyContent = variantKey.makeContent()
        defer { gi.variant_destroy(&keyContent) }
        withUnsafePointer(to: keyContent) { pArg0 in
            withUnsafePointer(to: UnsafeRawPointersN1(pArg0)) { pArgs in
                pArgs.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 1) { pArgs in
                    GodotInterfaceForDictionary.method_erase(&content, pArgs, &result, 1)
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
