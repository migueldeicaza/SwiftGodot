//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

@_implementationOnly import GDExtension

extension StringName: CustomStringConvertible, Hashable {
    /// Creates a StringName from a Swift String.Substring
    public convenience init (_ from: String.SubSequence) {
        self.init (from: String (from))
    }
    
    /// Returns a Swift string from the StringName
    public var description: String {
        let buffer = toUtf8Buffer()
        return buffer.getStringFromUtf8().description
    }
    
    public func hash (into hasher: inout Hasher) {
        hasher.combine (hash ())
    }
    
    /// Compares two StringNames for equality.
    public static func == (lhs: StringName, rhs: StringName) -> Bool {
        lhs.content == rhs.content
    }
}

func stringToGodotHandle (_ str: String) -> GDExtensionStringPtr {
    var ret = GDExtensionStringPtr (bitPattern: 0)
    gi.string_new_with_utf8_chars (&ret, str)
    return ret!
}

func stringFromGodotString (_ ptr: UnsafeRawPointer) -> String? {
    let n = gi.string_to_utf8_chars (ptr, nil, 0)

    return withUnsafeTemporaryAllocation (of: CChar.self, capacity: Int(n+1)) { strPtr in
        // The returned size is in chars, not bytes, so not very useful for us
        _ = gi.string_to_utf8_chars (ptr, strPtr.baseAddress, n)
        strPtr [Int (n)] = 0
        return String (cString: strPtr.baseAddress!)
    }
}
    
extension GString: CustomStringConvertible, Hashable {
    /// Returns a Swift string from a pointer to a native Godot string
    static func stringFromGStringPtr (ptr: UnsafeRawPointer?) -> String? {
        guard let ptr else {
            return nil
        }
        let len = gi.string_to_utf8_chars (UnsafeMutableRawPointer (mutating: ptr), nil, 0)
        return withUnsafeTemporaryAllocation(of: CChar.self, capacity: Int(len+1)) { strPtr in
            // Return is in characters, not bytes, not very useful
            _ = gi.string_to_utf8_chars (UnsafeMutableRawPointer (mutating: ptr), strPtr.baseAddress, len)
            strPtr [Int (len)] = 0
            return String (cString: strPtr.baseAddress!)
        }
    }
    
    /// Returns a Swift string from this GString.
    public var description: String {
        get {
            return withUnsafeBytes(of: &content) { ptr in
                let len = gi.string_to_utf8_chars (ptr.baseAddress, nil, 0)
                return withUnsafeTemporaryAllocation(of: CChar.self, capacity: Int(len+1)) { strPtr in
                    _ = gi.string_to_utf8_chars (ptr.baseAddress, strPtr.baseAddress, len)
                    strPtr [Int (len)] = 0
                    return String (cString: strPtr.baseAddress!)
                } ?? ""
            }
        }
    }
    
    public func hash (into hasher: inout Hasher) {
        hasher.combine (hash ())
    }
}

extension String {
    public init (_ n: StringName) {
        self = n.description
    }
}

