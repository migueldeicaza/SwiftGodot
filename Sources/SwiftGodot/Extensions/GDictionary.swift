//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/23/23.
//

extension GDictionary: CustomDebugStringConvertible, CustomStringConvertible {
    /// Convenience subscript that uses a String as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    public subscript (key: String) -> Variant? {
        get {
            return self [Variant (key)]
        }
        set {
            self [Variant (key)] = newValue
        }
    }
    
    /// Convenience subscript that uses a StringName as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    public subscript (key: StringName) -> Variant? {
        get {
            return self [Variant (key)]
        }
        set {
            self [Variant (key)] = newValue
        }
    }

    /// Renders the dictionary using the `Variant`'s `description` method.
    public var debugDescription: String {
        Variant (self).description
    }

    /// Renders the dictionary using the `Variant`'s `description` method.
    public var description: String {
        Variant (self).description
    }
}
