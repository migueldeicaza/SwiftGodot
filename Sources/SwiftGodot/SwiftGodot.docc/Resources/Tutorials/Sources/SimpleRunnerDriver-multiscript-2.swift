// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftGodot

let allNodes: [Wrapped.Type] = [PlayerController.self, MainLevel.self]

#initSwiftExtension(cdecl: "swift_entry_point", types: allNodes)
