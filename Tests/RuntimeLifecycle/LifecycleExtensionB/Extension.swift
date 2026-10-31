import SwiftGodot

@Godot
class LifecycleProbeB: Node {
    @Callable
    func makeNativeResource() -> Int64 {
        let resource = Resource()
        return Int64(bitPattern: UInt64(resource.getInstanceId()))
    }
}

#initSwiftExtension(cdecl: "lifecycle_b_entry_point", types: [LifecycleProbeB.self])
