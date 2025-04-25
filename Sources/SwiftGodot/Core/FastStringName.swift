//
//  FastStringName.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 16/04/2025.
//

@_implementationOnly import GDExtension

/// A fast wrapper similar to ``StringName``, but relying on Swift ``StaticString`` to avoid allocations if possible.
public struct FastStringName: ~Copyable {
    enum Source {
        case staticString(StaticString, isStatic: Bool)
        case string(String)
    }
    
    var content: StringName.ContentType
    let source: Source
    var isStatic: Bool {
        switch source {
        case .staticString(_, let isStatic):
            return isStatic
        case .string:
            return false
        }
    }
    
    var description: String {
        switch source {
        case .staticString(let staticString, let isStatic):
            return staticString.description
        case .string(let string):
            return string
        }
    }
    
    /// Create ``FastStringName`` by wrapping static storage of ``StaticString``, if there is one, or goes the slow path if there is none.
    ///
    /// ### WARNING
    /// Godot only allows creating `StringName` that way only with `latin1` encoding. That effectively means that your string is assumed to
    /// contain only ASCII characters to be compatible with arbitary `utf8` representation of `StaticString`
    /// If `string` contains anything else, the behavior is undefined
    public init(_ unsafeLatin1String: StaticString) {
        let isStatic = unsafeLatin1String.hasPointerRepresentation
        source = .staticString(unsafeLatin1String, isStatic: isStatic)
        
        content = unsafeLatin1String.withUTF8Buffer { noTerminatorBuffer in
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
    
    /// Create ``FastStringName`` from ``String``.
    ///
    /// ### WARNING
    /// Godot only allows creating `StringName` that way only with `latin1` encoding. That effectively means that your string is assumed to
    /// contain only ASCII characters to be compatible with arbitary `utf8` representation of `String`
    /// If `string` contains anything else, the behavior is undefined
    @_disfavoredOverload
    public init(_ unsafeLatin1String: String) {
        source = .string(unsafeLatin1String)
        var content = StringName.zero
        gi.string_name_new_with_latin1_chars(&content, unsafeLatin1String, 0 /* p_is_static = false */)
        self.content = content
    }
    
    deinit {
        guard !isStatic else {
            return
        }
        
        var content = content
        GodotInterfaceForStringName.destructor(&content)
    }
}
