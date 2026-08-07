extends Control
@onready var ui_agent_spawn_button:CheckButton = %AgentSpawnButton
@onready var ui_agent_count_box:SpinBox = %AgentCountBox

func _physics_process(_delta: float) -> void:
	ui_agent_count_box.value = get_tree().get_node_count_in_group("overworld_agents")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause_game"):
		get_tree().paused = !get_tree().paused
	get_viewport().set_input_as_handled()
