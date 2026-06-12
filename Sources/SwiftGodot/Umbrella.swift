// The SwiftGodot umbrella module: re-exports every split module so existing
// `import SwiftGodot` code keeps working, and (together with the package's
// macro plugin) makes `@Godot`/`@Export`/etc. available to consumers.
@_exported import SwiftGodotRuntime
@_exported import SwiftGodotCore
@_exported import SwiftGodotControls
@_exported import SwiftGodot2D
@_exported import SwiftGodot3D
@_exported import SwiftGodotGLTF
@_exported import SwiftGodotVisualShaderNodes
@_exported import SwiftGodotXR
@_exported import SwiftGodotEditor
