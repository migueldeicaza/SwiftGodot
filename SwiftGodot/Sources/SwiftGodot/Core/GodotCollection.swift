//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 3/28/23.
//

import Foundation
import GDExtension

public class GodotCollection<T>: GArray {
    override init (content: Int64) {
        super.init (content: content)
    }
    public override init () {
        super.init ()
    }
}
