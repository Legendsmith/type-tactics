extends Control
@onready var ui_agent_spawn_button:CheckButton = %AgentSpawnButton
@onready var ui_agent_count_box:SpinBox = %AgentCountBox

func _physics_process(_delta: float) -> void:
	ui_agent_count_box.value = get_tree().get_node_count_in_group("overworld_agents")
