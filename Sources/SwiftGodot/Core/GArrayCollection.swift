//
//  VariantArrayCollection.swift
//
//
//  Created by Estevan Hernandez on 11/28/23.
//

@_implementationOnly import GDExtension

// If our exported Collections conform to this protocol, then we can use the same Macro code while exporting them
@usableFromInline
protocol VariantArrayCollection: Collection where Element: _GodotBridgeable {
    var array: VariantArray { nonmutating set get }
}
