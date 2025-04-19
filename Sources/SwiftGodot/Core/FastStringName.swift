//
//  FastStringName.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 16/04/2025.
//

@_implementationOnly import GDExtension

/// A fast wrapper similar to ``StringName``, but relying on Swift ``StaticString`` to avoid allocations.
struct FastStringName: ~Copyable {
    var content: StringName.ContentType
    var isStatic: Bool
    
    /// Create ``FastStringName`` by wrapping static storage of ``StaticString``, if there is one, or goes the slow path if there is none.
    ///
    /// ### WARNING
    /// Godot only allows creating `StringName` that way only with `latin1` encoding. That effectively means that your string is assumed to
    /// contain only ASCII characters to be compatible with arbitary `utf8` representation of `StaticString`
    /// If `string` contains anything else, the behavior is undefined
    init(_ string: StaticString) {
        let isStatic = string.hasPointerRepresentation
        self.isStatic = isStatic
        
        content = string.withUTF8Buffer { noTerminatorBuffer in
            noTerminatorBuffer.withMemoryRebound(to: CChar.self) { noTerminatorBuffer in
                return withUnsafeTemporaryAllocation(of: CChar.self, capacity: noTerminatorBuffer.count + 1) { pString in
                    noTerminatorBuffer.withMemoryRebound(to: CChar.self) { noTerminatorBuffer in
                        _ = pString.initialize(from: noTerminatorBuffer)
                    }
                    
                    pString.initializeElement(at: noTerminatorBuffer.count, to: 0)
                    
                    let p_is_static: GDExtensionBool = isStatic ? 1 : 0
                    var content = StringName.zero
                    gi.string_name_new_with_latin1_chars(&content, pString.baseAddress, p_is_static)
                    return content
                }
            }
        }
    }
        
    /// For test only.
    var description: String {
        let string = StringName(takingOver: content)
        let result = string.description
        string.content = .zero
        return result
    }
    
    
    deinit {
        guard !isStatic else {
            return
        }
        
        var content = content
        StringName.destructor(&content)
    }
}
