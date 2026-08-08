extends LimboState

@export var state_animation:StringName = &"idle"
@export var move_action:GUIDEAction = load("uid://fy1bkr5ine6w")

func _update(_delta: float) -> void:
	var input_dir = move_action.value_axis_2d.normalized()
	agent.desired_velocity = input_dir
