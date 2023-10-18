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
    
    let docClass = loadClassDoc(base: docRoot, name: "@GlobalScope")
    let emptyUsedMethods = Set<String>()
    
    p ("public class GD") {
        for method in values {
            // We ignore the request for virtual methods, should not happen for these
            
            _ = methodGen (p, method: method, className: "Godot", cdef: nil, docClass: docClass, usedMethods: emptyUsedMethods, kind: .utility, asSingleton: false)
            
        }
    }
}
