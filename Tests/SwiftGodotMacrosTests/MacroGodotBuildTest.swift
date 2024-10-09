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
class Demo1: Object {
    @Export var demo: GArray = GArray()
    
    @Export var greetings: VariantCollection<String> = []
    
    @Export var servers: ObjectCollection<AudioServer> = []
}

@Godot
class Demo2: Object {
    @Export var demo: Variant? = nil
}

enum Demo3: Int, CaseIterable {
    case first
}
enum Demo4: Int64, CaseIterable {
    case first
    case second
}

@Godot
class Demo5: Node {
    @Export(.enum) var foo: Demo3
    @Export(.enum) var bar: Demo4
    
    required init() {
        foo = .first
        bar = .second
        
        super.init()
    }
    
    required init(nativeHandle: UnsafeRawPointer) {
        foo = .first
        bar = .second
        
        super.init(nativeHandle: nativeHandle)
    }
}

@Godot
class Demo6: Node {
    @Export
    var greetings: VariantCollection<String> = []
}

@Godot
class Demo7: Node {
    @Export var someArray: GArray = GArray()
}
