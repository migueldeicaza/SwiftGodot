//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

import Foundation

extension StringName {
    public convenience init (_ string: String) {
        self.init (from: GString(string))
    }
}

extension GString {
    public var description: String {
        get {
            let len = gi.string_to_utf8_chars (UnsafeRawPointer (handle), nil, 0)
            let size = len+1
            let strPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: Int (size))
            (strPtr + Int(size)).initialize (to: 0)
            
            gi.string_to_utf8_chars (UnsafeRawPointer (handle), strPtr, len)
            let str = String (cString: strPtr)
            strPtr.deallocate()
            return str ?? ""
        }
    }
}
