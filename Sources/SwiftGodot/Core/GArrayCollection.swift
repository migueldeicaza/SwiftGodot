//
//  GArrayCollection.swift
//
//
//  Created by Estevan Hernandez on 11/28/23.
//

@_implementationOnly import GDExtension

// If our exported Collections conform to this protocol, then we can use the same Macro code while exporting them
protocol GArrayCollection: Collection where Element: VariantStorable {
	var array: GArray { set get }
}
