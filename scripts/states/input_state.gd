extends LimboState

@export var state_animation:StringName = &"idle"

func _update(_delta: float) -> void:
	var input_dir = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	agent.desired_velocity = input_dir
