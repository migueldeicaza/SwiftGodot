//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/8/23.
//

import Foundation
@_implementationOnly import GDExtension

public enum ArrayError {
    case outOfRange
}
public extension GArray {
    public subscript (index: Int) -> Variant {
        get {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return Variant()
            }
            let ptr = ret.assumingMemoryBound(to: Variant.ContentType.self)
            return Variant(fromContent: ptr.pointee)
        }
        set {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return
            }
            let ptr = ret.assumingMemoryBound(to: Variant.ContentType.self)
            ptr.pointee = newValue.content
        }
    }
}
