extends BTAction

@export var pos_variable:StringName = &"pos"
@export var node_variable:StringName = &"target"

func _tick(_delta: float) -> Status:
	blackboard.set_var(pos_variable,blackboard.get_var(node_variable).global_position)
	return SUCCESS
