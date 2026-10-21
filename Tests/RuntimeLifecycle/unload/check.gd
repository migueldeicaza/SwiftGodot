extends SceneTree

const A = "res://bin/LifecycleExtensionA.gdextension"
const B = "res://bin/LifecycleExtensionB.gdextension"
var failed := false
var leaked := false

func check(condition: bool, message: String) -> bool:
    if not condition:
        push_error("LIFECYCLE_FAILURE: " + message)
        failed = true
    return condition

func _initialize() -> void:
    run.call_deferred()

func check_resource(probe: Object, stage: String) -> void:
    var resource_ids: Array[int] = []
    for index in range(16):
        var resource_id: int = probe.call("makeNativeResource")
        if not check(resource_id != 0, stage + ": resource ID is zero"):
            return
        resource_ids.append(resource_id)
    for frame in range(8):
        await process_frame
    var stage_leaked := false
    for resource_id in resource_ids:
        if is_instance_id_valid(resource_id):
            stage_leaked = true
            leaked = true
            push_error("LIFECYCLE_LEAK: " + stage + " resource ID " + str(resource_id))
    if not stage_leaked:
        print("LIFECYCLE_RELEASED: " + stage)

func run() -> void:
    if not check(GDExtensionManager.load_extension(A) == GDExtensionManager.LOAD_STATUS_OK, "load A"):
        quit(1)
        return
    if not check(GDExtensionManager.load_extension(B) == GDExtensionManager.LOAD_STATUS_OK, "load B"):
        quit(1)
        return
    check(ClassDB.class_exists("LifecycleNodeA"), "A class is absent")
    var node = ClassDB.instantiate("LifecycleNodeA")
    if not check(node != null, "create A"):
        quit(1)
        return
    await check_resource(node, "extension_a")
    node.free()
    node = null
    var probe = ClassDB.instantiate("LifecycleProbeB")
    if not check(probe != null, "create B probe"):
        quit(1)
        return
    await check_resource(probe, "before_unload")
    check(GDExtensionManager.unload_extension(A) == GDExtensionManager.LOAD_STATUS_OK, "unload A")
    check(not ClassDB.class_exists("LifecycleNodeA"), "A class remains after unload")
    await check_resource(probe, "after_unload")
    check(GDExtensionManager.load_extension(A) == GDExtensionManager.LOAD_STATUS_OK, "reload A")
    check(ClassDB.class_exists("LifecycleNodeA"), "A class is absent after reload")
    await check_resource(probe, "after_reload")
    check(GDExtensionManager.unload_extension(A) == GDExtensionManager.LOAD_STATUS_OK, "unload reloaded A")
    probe.free()
    probe = null
    for frame in range(8):
        await process_frame
    check(GDExtensionManager.unload_extension(B) == GDExtensionManager.LOAD_STATUS_OK, "unload B")
    check(not ClassDB.class_exists("LifecycleNodeA"), "A class remains")
    check(not ClassDB.class_exists("LifecycleProbeB"), "B class remains")
    if failed:
        quit(1)
    elif leaked:
        print("LIFECYCLE_UNLOAD_LEAK")
        quit(2)
    else:
        print("LIFECYCLE_UNLOAD_OK")
        quit(0)
