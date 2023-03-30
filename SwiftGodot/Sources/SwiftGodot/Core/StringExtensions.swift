//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation
import GDExtension

extension StringName: Equatable {
    public convenience init (_ string: String) {
        self.init (from: GString(string))
    }
    
    public var description: String {
        let buffer = toUtf8Buffer()
        return buffer.getStringFromUtf8().description
    }
    
    public static func == (lhs: StringName, rhs: StringName) -> Bool {
        lhs.handle == rhs.handle
    }
}

// TODO make sure we release
func stringToGodotHandle (_ str: String) -> GDExtensionStringPtr {
    var ret = GDExtensionStringPtr (bitPattern: 0)
    gi.string_new_with_utf8_chars (&ret, str)
    return ret!
}

extension GString {
    public var description: String {
        get {
            let len = gi.string_to_utf8_chars (UnsafeRawPointer (&handle), nil, 0)
            let size = len+1
            let strPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: Int (size))
            (strPtr + Int(size)).initialize (to: 0)
            
            gi.string_to_utf8_chars (UnsafeRawPointer (&handle), strPtr, len)
            let str = String (cString: strPtr)
            strPtr.deallocate()
            return str ?? ""
        }
    }
}
