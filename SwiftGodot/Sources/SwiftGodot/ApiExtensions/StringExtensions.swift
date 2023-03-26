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
