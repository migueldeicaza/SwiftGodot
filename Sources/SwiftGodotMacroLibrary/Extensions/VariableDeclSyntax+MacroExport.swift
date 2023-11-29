//
//  TypeSyntax+MacroExport.swift
//
//
//  Created by Estevan Hernandez on 11/22/23.
//

import SwiftSyntax

extension VariableDeclSyntax {
    /// Returns `true` if type is either `[Element]` or `Array<Element>`
    var isArray: Bool {
        type?.isSquareArray == true || type?.isGenericArray == true
    }
    
    var isGArrayCollection: Bool {
        isVariantCollection || isObjectCollection
    }
    
    var gArrayCollectionElementTypeName: String? {
        [
            variantCollectionElementTypeName,
            objectCollectionElementTypeName
        ]	.compactMap { $0 }
            .first
    }
}

private extension VariableDeclSyntax {
    var type: TypeSyntax? {
        guard let last = bindings.last,
              let type = last.typeAnnotation?.type else {
            return nil
        }
        return type
    }
    
    /// Returns `true` if type is a `VariantCollection<Element>`
    var isVariantCollection: Bool {
        type?.isVariantCollection == true
    }
    
    /// Returns `true` if type is a `ObjectCollection<Element>`
    var isObjectCollection: Bool {
        type?.isObjectCollection == true
    }
    
    /// Returns `"Element"` for `VariantCollection<Element>`
    var variantCollectionElementTypeName: String? {
        guard isVariantCollection else {
            return nil
        }
        
        return type?.variantCollectionElementTypeName ?? genericInitializerElementTypeName
    }
    
    /// Returns `"Element"` for `ObjectCollection<Element>`
    var objectCollectionElementTypeName: String? {
        guard isObjectCollection else {
            return nil
        }
        
        return type?.objectCollectionElementTypeName ?? genericInitializerElementTypeName
    }
    
    var genericInitializerElementTypeName: String? {
        guard let elementTypeName = bindings
            .first?
            .initializer?
            .value
            .as(FunctionCallExprSyntax.self)?
            .calledExpression
            .as(GenericSpecializationExprSyntax.self)?
            .genericArgumentClause
            .arguments
            .first?
            .as(GenericArgumentSyntax.self)?
            .argument
            .as(IdentifierTypeSyntax.self)?
            .genericElementName
        else {
            return nil
        }
        
        return elementTypeName
    }
}

extension TypeSyntax {
    var isGArrayCollection: Bool {
        isVariantCollection || isObjectCollection
    }
}

private extension TypeSyntax {
    var isArray: Bool {
        isSquareArray || isGenericArray
    }
    
    var isSquareArray: Bool {
        self.is(ArrayTypeSyntax.self)
    }
    
    // Array<String> for example
    var isGenericArray: Bool {
        self.as(IdentifierTypeSyntax.self)?.name.text == "Array"
    }
    
    var isVariantCollection: Bool {
        self.as(IdentifierTypeSyntax.self)?.name.text == "VariantCollection"
    }
    
    var isObjectCollection: Bool {
        self.as(IdentifierTypeSyntax.self)?.name.text == "ObjectCollection"
    }
    
    var variantCollectionIdentifier: IdentifierTypeSyntax? {
        guard let identifier = self.as(IdentifierTypeSyntax.self),
              identifier.name.text == "VariantCollection" else {
            return nil
        }
        return identifier
    }
    
    var variantCollectionElementTypeName: String? {
        guard let identifier = variantCollectionIdentifier,
              let elementTypeName = identifier.genericElementName else {
            return nil
        }
        
        return elementTypeName
    }
    
    var objectCollectionIdentifier: IdentifierTypeSyntax? {
        guard let identifier = self.as(IdentifierTypeSyntax.self),
              identifier.name.text == "ObjectCollection" else {
            return nil
        }
        return identifier
    }
    
    var objectCollectionElementTypeName: String? {
        guard let identifier = objectCollectionIdentifier,
              let elementTypeName = identifier.genericElementName else {
            return nil
        }
        
        return elementTypeName
    }
}

private extension IdentifierTypeSyntax {
    var genericElementName: String? {
        guard let elementTypeName = genericArgumentClause?
            .arguments
            .first?
            .argument
            .as(IdentifierTypeSyntax.self)?
            .name
            .text else {
            return nil
        }
        
        return elementTypeName
    }
}
