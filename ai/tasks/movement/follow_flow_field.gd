@tool
extends BTAction
## Makes the agent follow a flow field
## Returns [code]SUCCESS[/code] when close to the target position (see [member tolerance]);
## otherwise returns [code]RUNNING[/code].

## Blackboard variable that stores the target position (Vector2)
@export var target_var := &"target"

## Variable that stores desired speed (float)
@export var speed_var := &"speed"

@export var approach_distance_default: float = 16.0


## How close should the agent be to the target position to return SUCCESS.
@export var tolerance := 32.0


func _generate_name() -> String:
	return "Follow Flow Field"

func _enter() -> void:
	var target:Node2D = blackboard.get_var(target_var)
	assert(target.is_in_group(Constants.FLOW_FIELD_GROUP),"Target %s is not in Flow Field group for Follow Flowfield action in agent %s!" % [target,agent])
	blackboard.set_var(&"pos",target.global_position)
	agent.activate_flow_field(target.flow_field)

func _tick(_delta: float) -> Status:
	if agent.global_position.distance_to(blackboard.get_var(target_var).global_position)<=approach_distance_default:
		agent.use_flow_field = false
		return SUCCESS
	else:
		return RUNNING

