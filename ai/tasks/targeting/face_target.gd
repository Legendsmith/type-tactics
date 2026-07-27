extends BTAction
@export var target_var:StringName = &"target"
#export_range(0,180,0.01,"radians_as_degrees") var tolerance:float = PI*.012

func _tick(_delta: float) -> Status:
	var target_point:Vector2 = blackboard.get_var(target_var).global_position
	agent.animation_player.play("idle_"+str(Constants.get_direction_index(agent.global_position.direction_to(target_point))))
	return SUCCESS
