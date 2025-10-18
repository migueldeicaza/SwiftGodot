//
//  InitializationLevel.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 10/16/25.
//

@_implementationOnly import GDExtension

public enum ExtensionInitializationLevel: Int64, Sendable {
    case core = 0
    case servers = 1
    case scene = 2
    case editor = 3
}

public typealias GodotInitializationLevel = ExtensionInitializationLevel

extension ExtensionInitializationLevel {
    init?(cLevel: GDExtensionInitializationLevel) {
        self.init(rawValue: Int64(cLevel.rawValue))
    }

    var cLevel: GDExtensionInitializationLevel {
        #if os(Windows)
            typealias RawType = Int32
        #else
            typealias RawType = UInt32
        #endif
        return GDExtensionInitializationLevel(RawType(rawValue))
    }
}
