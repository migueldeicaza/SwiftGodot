import SwiftGodot

@Godot
class LifecycleNodeA: Node {
    @Callable
    func makeNativeResource() -> Int64 {
        let resource = Resource()
        return Int64(bitPattern: UInt64(resource.getInstanceId()))
    }
}

#initSwiftExtension(cdecl: "lifecycle_a_entry_point", types: [LifecycleNodeA.self])
