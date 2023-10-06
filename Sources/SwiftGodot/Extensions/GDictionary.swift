//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/23/23.
//

public extension GDictionary {
    /// Convenience subscript that uses a String as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    subscript (key: String) -> Variant? {
        get {
            return self [Variant (key)]
        }
        set {
            self [Variant (key)] = newValue
        }
    }
    
    /// Convenience subscript that uses a StringName as the key to access the
    /// elements in the dictionary.   Merely wraps this on a Variant.
    subscript (key: StringName) -> Variant? {
        get {
            return self [Variant (key)]
        }
        set {
            self [Variant (key)] = newValue
        }
    }
}
