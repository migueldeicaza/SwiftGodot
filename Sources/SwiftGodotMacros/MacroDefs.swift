//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 9/25/23.
//

import Foundation
import SwiftGodot

@attached(member, 
          names: named (init(nativeHandle:)), named (init()), named(_initClass), arbitrary)
public macro Godot() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotMacro")

@attached(peer, names: prefixed(_mproxy_))
public macro Callable() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotCallable")

@attached(accessor)
public macro Export() = #externalMacro(module: "SwiftGodotMacroLibrary", type: "GodotExport")

