extends Node

func _ready() -> void:
	if SwiftTestState.score != 99 or SwiftTestState.ready_count != 1:
		push_error("Swift autoload state must remain across scene changes")
		get_tree().quit(1)
		return
	if SwiftTestState.get_instance_id() != get_tree().get_meta("autoload_instance"):
		push_error("Scene changes must retain the same Swift autoload instance")
		get_tree().quit(1)
		return
	print("SwiftGodot autoload integration passed")
	get_tree().quit(0)
