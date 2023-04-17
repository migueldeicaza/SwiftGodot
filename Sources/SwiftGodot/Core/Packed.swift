//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//

import Foundation

extension PackedStringArray {
    convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: x)
        }
    }

    public subscript (index: Int) -> String {
        get {
            // On the fence, I think that I should just create a GString here, instead of a String
            // TODO: but need the right constructor.
            fatalError ()
            // GString.stringFromGStringPtr(ptr: gi.packed_string_array_operator_index (&content, Int64 (index)))!
        }
        set {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return
            }
            fatalError ()
            // TODO Need to call Set here
        }
    }

}
