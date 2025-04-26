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
    @Export var demo: VariantArray = VariantArray()
    @Export var greetings: TypedArray<String> = []
    @Export var servers: TypedArray<AudioServer?> = []
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
    
    
    required init(_ nativeHandle: NativeObjectHandle) {
        foo = .first
        bar = .second
        
        super.init(nativeHandle)
    }
}

@Godot
class Demo6: Node {
    @Export
    var greetings: TypedArray<String> = []
}

@Godot
class Demo7: Node {
    @Export var someArray: VariantArray = VariantArray()
    @Export var someNumbers: TypedArray<Int> = []
}

@Godot
class Demo8: Node {
    @Export var someNumbers: TypedArray<Int> = []
    @Export var someOtherNumbers: TypedArray<Int> = []
}

@Godot
class Demo9: Node {
    @Export var someNumbers: TypedArray<Int> = []
}

@Godot
class Demo10: Node {
   @Export var firstNames: TypedArray<String> = ["Thelonius"]
   @Export var lastNames: TypedArray<String> = ["Monk"]
}

@Godot
class Demo11: Node {
    @Export var greetings: TypedArray<Node3D?> = []
}

@Godot
class Demo12: Node {
    @Export var greetings: TypedArray<Node3D?> = []
}

@Godot
class Demo13: Node {
    #exportGroup("Vehicle")
    @Export var makes: TypedArray<Node?> = []
    @Export var model: TypedArray<Node?> = []
}

@Godot
class Demo14: Node {
    @Export var vins: TypedArray<Node?> = []
    #exportGroup("YMMS")
    @Export var years: TypedArray<Node?> = []
}

@Godot
class Demo15: Node {
    #exportGroup("VIN")
    @Export var vins: TypedArray<Node?> = []
    #exportGroup("YMM")
    @Export var years: TypedArray<Node?> = []
    @Export var makes: TypedArray<Node?> = []
    @Export var models: TypedArray<Node?> = []
    
}

@Godot
class Demo16: Node {
    #exportGroup("Front Page")
    @Export var demoName: String = ""
    @Export var rating: Float = 0.0
    #exportGroup("More Details")
    @Export var reviews: TypedArray<String> = []
    @Export var checkIns: TypedArray<Object?> = []
    @Export var address: String = ""
    #exportGroup("Hours and Insurance")
    @Export var daysOfOperation: TypedArray<String> = []
    @Export var hours: TypedArray<String> = []
    @Export var insuranceProvidersAccepted: TypedArray<Object?> = []
}

@Godot
public class Demo17: Node {
    #exportGroup("Group With a Prefix", prefix: "prefix1")
    @Export var prefix1_prefixed_bool: TypedArray<Bool> = [false]
    @Export var non_prefixed_bool: TypedArray<Bool> = [false]
}

@Godot class Demo18: Node {
    @Callable func deleteEpisode() {}
    @Callable func subscribe(podcast: Object) {}
    @Callable func removeSilences(from: Variant) {}
    @Callable func getLatestEpisode(podcast: Object) -> Object {
        return Object()
    }
    @Callable func queue(_ podcast: Object, after preceedingPodcast: Object) {}
}

@Godot
final class Demo19: Resource {}

@Godot
final class Demo20: Node {
    @Export var data: Demo19 = Demo19()
}

@Godot
final class Demo21: Node {
    @Export var data: Demo19? = nil
}

@Godot class Demo22: Node {
    #exportGroup("Vehicle")
    #exportSubgroup("VIN")
    @Export var vin: String = ""
    #exportSubgroup("YMMS", prefix: "ymms_")
    @Export var ymms_year: Int = 1998
    @Export var ymms_make: String = "Honda"
    @Export var ymms_model: String = "Odyssey"
    @Export var ymms_series: String = "LX"
}

@Godot
class SomeNode: Node {
    @Callable
    func printNames(of nodes: TypedArray<Node?>) {
        _ = nodes[0]
        
        nodes.forEach { print($0?.name ?? "") }
    }
    
    @Callable
    func printWhatever(of nodes: TypedArray<Node?>, string: String, int: Int) {
        nodes.forEach { print($0?.name ?? "") }
    }
}

@Godot
class DebugThing: SwiftGodot.Object {
    @Signal var livesChanged: SignalWithArguments<Swift.Int>
    
    @Callable
    func do_thing(value: Swift.Int) -> SwiftGodot.Variant? {
        return nil
    }
    
    @Callable
    func explicitVoid(value: Swift.Int) -> Void {
        return
    }    
}

@Godot class MyThing: SwiftGodot.RefCounted {
    @Callable
    func nodeAddedToScene(node: Node?) {
        
    }
}

@Godot class ObjectWithCallableReturningOptionalObject: SwiftGodot.Node {
    @Callable func get_thing() -> MyThing? {
        return nil
    }
}

@Godot class ObjectWithCallableTakingOptionalBuiltin: SwiftGodot.Node {
    @Callable func do_int(value: Int?) {  }
    @Callable func do_string(value: String?) { }
}

@Godot class ObjectWithFunctionTakingAndReturningOptionalVariant: SwiftGodot.Node {
    @Callable
    func bar(_ value: Variant?) -> Variant? {
        return value
    }
}

@Godot class NodeWithNewCallableAutoSnakeCase: Node {
    @Callable(autoSnakeCase: true)
    func noNeedToSnakeCaseFunctionsNow() {}

    @Callable(autoSnakeCase: false)
    func or_is_there() {}

    @Callable
    func defaultIsLegacyCompatible() {}
}

/* comment */@Godot(
.tool/* comment */) // like this
/* comment */class /* comment */NodeWithCommentsInRandomPlaces/* comment */: /* comment */Node /* comment */{
    /* comment */@Signal/* comment */ var/* comment */ signal/* comment */: /* comment */ SimpleSignal // Comment
    @Callable/* comment */
    public /* comment */func /* comment */foo/* comment */(
        /* comment */lala/* comment */:/* comment */ Int // COMMENT
    )/* comment */ -> /* comment */ Int // COMMENT
    /* comment */{/* comment */
        0
    }/* comment */
}
