//
//  UtilityGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 5/14/23.
//

import Foundation
import ExtensionApi

func generateUtility(values: [JGodotUtilityFunction], outputDir: String?) async {
    let p = await PrinterFactory.shared.initPrinter()
    p.preamble()
    defer {
        if let outputDir {
            p.save (outputDir + "utility.swift")
        }
    }
    
    let emptyUsedMethods = Set<String>()
    
    p ("public class GD") {
        for method in values {
            // We ignore the request for virtual methods, should not happen for these
            if omittedMethodsList["utility_functions"]?.contains(method.name) == true {
                continue
            }
            
            _ = methodGen (p, method: method, className: "Godot", cdef: nil, usedMethods: emptyUsedMethods, kind: .utility, asSingleton: false)
        }
    }
}
