import SwiftGodot

@Godot
final class AutoloadCompileProbe: Node {}

// Check the overload with no explicit registration list.
#initSwiftExtension(
    cdecl: "swiftgodot_autoload_compile_entry",
    autoloads: [.init(name: "SwiftCompileGlobal", type: AutoloadCompileProbe.self)]
)
