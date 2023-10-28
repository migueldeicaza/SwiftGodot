//
//  Convertible.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-22.
//

@_implementationOnly import GDExtension
 
/// Types that can be converted into types that can be wrapped in a Variant
/// Example: A string can't be stored in a variant, but a GString can, so String can be
/// VariantConvertible into a GString, which can be VariantRepresentable
public protocol VariantConvertible {
    func toVariantRepresentable() -> VariantRepresentable
    init?(_ variant: Variant)
}

extension Variant {
    public convenience init(_ value: some VariantConvertible) {
        self.init(value.toVariantRepresentable())
    }
}

extension String: VariantConvertible {
    public func toVariantRepresentable() -> VariantRepresentable {
        GString(stringLiteral: self)
    }
    
    public init?(_ variant: Variant) {
        guard let gString = GString(variant) else { return nil }
        self = gString.description
    }
}

extension Bool: VariantConvertible {
    public func toVariantRepresentable() -> VariantRepresentable {
        GDExtensionBool(self ? 1 : 0)
    }
    
    public init?(_ variant: Variant) {
        guard let gBool = GDExtensionBool(variant) else { return nil }
        self = gBool == 1
    }
}

extension Int: VariantConvertible {
    public func toVariantRepresentable() -> VariantRepresentable {
        Int64(self)
    }
    
    public init?(_ variant: Variant) {
        guard let int = GDExtensionInt(variant) else { return nil }
        self = Int(int)
    }
}
