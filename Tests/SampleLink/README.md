This is a testbed to exercise static linking in SwiftGodot.

It inclues two targets, an executable, intended to test just how much
static code is linked when referencing the library, and a dynamic one
intended to create a dynamic library that can be used in Godot.

They both reference the "SwiftGodotStatic" product from SwiftGodot,
even if one of these targets is dynamic.



