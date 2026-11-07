extends Node

func _ready() -> void:
	if SwiftTestState.ready_count != 1 or not SwiftTestObserver.saw_state_ready:
		fail("Autoload callbacks must run in declaration order before the main scene")
		return
	SwiftTestState.score = 99
	get_tree().set_meta("autoload_instance", SwiftTestState.get_instance_id())
	await get_tree().process_frame
	await get_tree().process_frame
	if SwiftTestState.process_count < 1:
		fail("Swift autoload must receive process callbacks")
		return
	if get_tree().change_scene_to_file("res://next.tscn") != OK:
		fail("Cannot change to the next scene")

func fail(message: String) -> void:
	push_error(message)
	get_tree().quit(1)
