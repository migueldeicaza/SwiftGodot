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
    @Export var someNumbers: VariantCollection<Int> = []
}

@Godot
class Demo8: Node {
    @Export var someNumbers: VariantCollection<Int> = []
    @Export var someOtherNumbers: VariantCollection<Int> = []
}

@Godot
class Demo9: Node {
    @Export var someNumbers: VariantCollection<Int> = []
}

@Godot
class Demo10: Node {
   @Export var firstNames: VariantCollection<String> = ["Thelonius"]
   @Export var lastNames: VariantCollection<String> = ["Monk"]
}

@Godot
class Demo11: Node {
    @Export var greetings: ObjectCollection<Node3D> = []
}

@Godot
class Demo12: Node {
    @Export var greetings: ObjectCollection<Node3D> = []
}

@Godot
class Demo13: Node {
    #exportGroup("Vehicle")
    @Export var makes: ObjectCollection<Node> = []
    @Export var model: ObjectCollection<Node> = []
}

@Godot
class Demo14: Node {
    @Export var vins: ObjectCollection<Node> = []
    #exportGroup("YMMS")
    @Export var years: ObjectCollection<Node> = []
}

@Godot
class Demo15: Node {
    #exportGroup("VIN")
    @Export var vins: ObjectCollection<Node> = []
    #exportGroup("YMM")
    @Export var years: ObjectCollection<Node> = []
    @Export var makes: ObjectCollection<Node> = []
    @Export var models: ObjectCollection<Node> = []
    
}

@Godot
class Demo16: Node {
    #exportGroup("Front Page")
    @Export var demoName: String = ""
    @Export var rating: Float = 0.0
    #exportGroup("More Details")
    @Export var reviews: VariantCollection<String> = []
    @Export var checkIns: ObjectCollection<Object> = []
    @Export var address: String = ""
    #exportGroup("Hours and Insurance")
    @Export var daysOfOperation: VariantCollection<String> = []
    @Export var hours: VariantCollection<String> = []
    @Export var insuranceProvidersAccepted: ObjectCollection<Object> = []
}

@Godot
public class Demo17: Node {
    #exportGroup("Group With a Prefix", prefix: "prefix1")
    @Export var prefix1_prefixed_bool: VariantCollection<Bool> = [false]
    @Export var non_prefixed_bool: VariantCollection<Bool> = [false]
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
    func printNames(of nodes: ObjectCollection<Node>) {
        nodes.forEach { print($0?.name ?? "") }
    }
    
    @Callable
    func printWhatever(of nodes: ObjectCollection<Node>, string: String, int: Int) {
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

@Godot class ObjectWithStaticFunctions: SwiftGodot.Node {
    @Callable
    class func bar(_ value: Variant?) -> Variant? {
        return value
    }
    
    @Callable
    static func staticFunc(_ something: String) -> Bool {
        something.isEmpty
    }
}
