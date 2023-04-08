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
            append(value: GString (x))
        }
    }
}
