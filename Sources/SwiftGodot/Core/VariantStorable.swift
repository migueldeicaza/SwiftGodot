//
//  VariantStorable.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-22.
//

@_implementationOnly import GDExtension
 
/// Something that can be wrapped in a Variant, either directly through `VariantRepresentable`
/// or by converting to a `VariantRepresentable`. 
public protocol VariantStorable {
    associatedtype Representable: VariantRepresentable
    
    /// Creates an instance using a variant
    init?(_ variant: Variant)
    
    func toVariantRepresentable() -> Representable
}

extension String: VariantStorable {
    public func toVariantRepresentable() -> GString {
        GString(stringLiteral: self)
    }
    
    public init?(_ variant: Variant) {
        guard let gString = GString(variant) else { return nil }
        self = gString.description
    }
}

extension Bool: VariantStorable {
    public func toVariantRepresentable() -> UInt8 {
        GDExtensionBool(self ? 1 : 0)
    }
    
    public init?(_ variant: Variant) {
        guard let gBool = GDExtensionBool(variant) else { return nil }
        self = gBool == 1
    }
}

extension Int: VariantStorable {
    public func toVariantRepresentable() -> Int64 {
        Int64(self)
    }
    
    public init?(_ variant: Variant) {
        guard let int = GDExtensionInt(variant) else { return nil }
        self = Int(int)
    }
}
