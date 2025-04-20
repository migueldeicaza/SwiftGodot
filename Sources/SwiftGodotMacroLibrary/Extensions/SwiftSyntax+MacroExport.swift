//
//  SwiftSyntax+MacroExport.swift
//
//
//  Created by Estevan Hernandez on 11/22/23.
//

import SwiftSyntax

extension VariableDeclSyntax {
    /// Returns `true` if type is either `[Element]` or `Array<Element>`
    var isSwiftArray: Bool {
        type?.isSwiftArray == true
    }
    
    var isVariantArrayCollection: Bool {
        type?.isVariantArrayCollection == true
    }
    
    var gArrayCollectionElementTypeName: String? {
        type?.gArrayCollectionElementTypeName
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
    
    /// Returns `true` if type is a `TypedArray<Element>`
    var isTypedArray: Bool {
        type?.isTypedArray == true
    }
    
    /// Returns `"Element"` for `TypedArray<Element>`
    var variantCollectionElementTypeName: String? {
        guard isTypedArray else {
            return nil
        }
        
        return type?.variantCollectionElementTypeName ?? genericInitializerElementTypeName
    }
    
    /// Returns `"Element"` for `TypedArray<Element>`
    var objectCollectionElementTypeName: String? {
        guard isTypedArray else {
            return nil
        }
        
        return type?.objectCollectionElementTypeName ?? genericInitializerElementTypeName
    }
    
    var genericInitializerElementTypeName: String? {
        guard let argument = bindings
            .first?
            .initializer?
            .value
            .as(FunctionCallExprSyntax.self)?
            .calledExpression
            .as(GenericSpecializationExprSyntax.self)?
            .genericArgumentClause
            .arguments
            .first,
        let elementTypeName = GenericArgumentSyntax (argument)?
            .argument
            .as(IdentifierTypeSyntax.self)?
            .genericElementName
        else {
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

extension TypeSyntax {
    var isSwiftArray: Bool {
        isSquareArray || isGenericArray
    }
    
    var arrayElementTypeName: String? {
        if isSquareArray, let arrayElementTypeName = self
            .as(ArrayTypeSyntax.self)?
            .element
            .as(IdentifierTypeSyntax.self)?
            .name
            .text {
            arrayElementTypeName
        } else if isGenericArray, let arrayElementTypeName = self
            .as(IdentifierTypeSyntax.self)?
            .genericElementName {
            arrayElementTypeName
        } else {
            nil
        }
    }
    
    var isVariantArrayCollection: Bool {
        isTypedArray || isTypedArray
    }
    
    var gArrayCollectionElementTypeName: String? {
        variantCollectionElementTypeName ?? objectCollectionElementTypeName
    }
}

private extension TypeSyntax {
    var isSquareArray: Bool {
        self.is(ArrayTypeSyntax.self)
    }
    
    // Array<String> for example
    var isGenericArray: Bool {
        self.as(IdentifierTypeSyntax.self)?.name.text == "Array"
    }
    
    var isTypedArray: Bool {
        self.as(IdentifierTypeSyntax.self)?.name.text == "TypedArray"
    }
    
    var variantCollectionIdentifier: IdentifierTypeSyntax? {
        guard let identifier = self.as(IdentifierTypeSyntax.self),
              identifier.name.text == "TypedArray" else {
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
              identifier.name.text == "TypedArray" else {
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

extension FunctionDeclSyntax {
    var isReturnedTypeSwiftArray: Bool {
        signature
            .returnClause?
            .type
            .isSwiftArray == true
    }
    
    var returnedSwiftArrayElementType: String? {
        signature
            .returnClause?
            .type
            .arrayElementTypeName
    }
    
    var isReturnedTypeVariantArrayCollection: Bool {
        signature
            .returnClause?
            .type
            .isVariantArrayCollection == true
    }
}

extension FunctionParameterSyntax {
    var isSwiftArray: Bool {
        type.isSwiftArray
    }
    
    var arrayElementTypeName: String? {
        type.arrayElementTypeName
    }
    
    /// Returns `true` if type is a `TypedArray<Element>`
    var isTypedArray: Bool {
        type.isTypedArray == true
    }
    
    /// Returns `"Element"` for `TypedArray<Element>`
    var variantCollectionElementTypeName: String? {
        guard isTypedArray else {
            return nil
        }
        
        return type.variantCollectionElementTypeName
    }
    
    /// Returns `"Element"` for `TypedArray<Element>`
    var objectCollectionElementTypeName: String? {
        guard isTypedArray else {
            return nil
        }
        
        return type.objectCollectionElementTypeName
    }
}
