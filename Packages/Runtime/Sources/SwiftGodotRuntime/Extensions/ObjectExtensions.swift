//
//  ObjectExtensions.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 11/13/25.
//

extension Object: CustomStringConvertible {
    public var description: String {
        return toString().description
    }
}
