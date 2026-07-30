@tool
extends BTAction
@export var target_var := &"target"


func _generate_name() -> String:
	return "Target Player: %s" % [
		LimboUtility.decorate_var(target_var)]

func _tick(_delta: float) -> Status:
	var new_target = agent.get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY)
	if not is_instance_valid(new_target):
		#print_debug("Failed to get player")
		return FAILURE
	blackboard.set_var(target_var,new_target)
	return SUCCESS
