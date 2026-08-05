extends BTAction
## Biases the resuting point's location to horizontal by modifying the random vector angle generated.
@export_range(-0.5,0.5,0.02) var x_bias:float = 0
@export var target_variable:StringName = &"target"
@export var position_variable:StringName = &"pos"
@export var min_distance:float = 600.0
@export var max_distance:float = 1920.0

func _tick(_delta: float) -> Status:
	var bias:Vector2 = Vector2(1+x_bias,1-x_bias)
	var target_pos:Vector2 = blackboard.get_var(target_variable,agent,false).global_position
	var direction_to:Vector2 = target_pos.direction_to(agent.global_position)
	var new_pos:Vector2 = target_pos + direction_to.rotated(PI*randf()) * bias * randf_range(min_distance,max_distance)
	blackboard.set_var(position_variable,new_pos)
	return SUCCESS
