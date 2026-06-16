extends Node
class_name TestOrchestrator

# Pure-GDScript entry point for the test run.
#
# The TestRunnerNode is *not* baked into main.tscn (that would make the saved
# scene depend on a SwiftGodot-provided type and keep the extension pinned).
# Instead we instantiate it at runtime, drive it, and free it again before
# quitting, so no extension instance survives to block a clean unload.
func _ready() -> void:
	var runner := TestRunnerNode.new()
	add_child(runner)

	# Run deferred so `runTests` can't emit `finished` before we await it below.
	runner.call_deferred("runTests")
	var exit_code: int = await runner.finished

	# The tests free their nodes with queue_free, so the actual deletions only
	# happen on a frame tick. Pump frames first so every test instance is gone...
	for _i in 10: # Safe grace period for Swift objects to get cleaned up
		await get_tree().process_frame

	# ...then deregister the classes (must happen AFTER their instances are freed).
	runner.deregisterTypes()

	# Now tear down the runner itself and let its free settle before quitting,
	# so no extension instance survives and the extension can be unloaded cleanly.
	runner.queue_free()

	for _i in 10:
		await get_tree().process_frame

	get_tree().quit(exit_code)
