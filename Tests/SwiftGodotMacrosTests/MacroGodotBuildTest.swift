// This file is solely here to ensure that we can compile the resulting macros,
// which is not covered by the macro output generation.

import SwiftGodot

@Godot
class Demo: Object {
	@Export var demo: GArray = GArray()
}

@Godot
class Demo2: Object {
	@Export var demo: Variant = Variant()
}
