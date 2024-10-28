//
// This file is solely here to ensure that we can compile the resulting macros,
// which is not covered by the macro output generation.
//
//
//  Created by Miguel de Icaza on 2/27/24.
//

import Foundation
import SwiftGodot

@Godot
class Demo: Object {
    @Export var demo: GArray = GArray()
}

@Godot
class Demo2: Object {
    @Export var demo: Variant = Variant()
}

@Godot
class Demo3: Object {
    @Callable func demo(options: VariantCollection<String>) {}
}

@Godot
class Demo4: Object {
    @Callable func demo(options: ObjectCollection<Node>) {}
}
