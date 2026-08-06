@tool
extends BTAction
## Makes the agent follow a flow field
## Returns [code]SUCCESS[/code] when close to the target position (see [member tolerance]);
## otherwise returns [code]RUNNING[/code].

## Blackboard variable that stores the target position (Vector2)
@export var target_var := &"target"

## Variable that stores desired speed (float)
@export var speed_var := &"speed"

## How close should the agent be to the target position to return SUCCESS.
@export var tolerance := 64

var _distance_squared:float

func _generate_name() -> String:
	return "Follow Flow Field"

func _setup() -> void:
	_distance_squared = tolerance ** 2

func _enter() -> void:
	var target:Node2D = blackboard.get_var(target_var)
	assert(target.is_in_group(Constants.FLOW_FIELD_GROUP),"Target %s is not in Flow Field group for Follow Flowfield action in agent %s!" % [target,agent])
	blackboard.set_var(&"pos",target.global_position)
	agent.linear_damp = 1
	if Vector2i(target.global_position/Constants.SPATIAL_HASH_SIZE) ==  Vector2i(agent.global_position/Constants.SPATIAL_HASH_SIZE):
		agent.activate_flow_field(target.flow_field)
	else:
		SpatialMap.agent_request_flow_field.emit(agent,agent.spatial_hash.hash_location)
		agent.activate_flow_field(agent.flow_field)

func _tick(_delta: float) -> Status:
	if agent.global_position.distance_squared_to(blackboard.get_var(target_var).global_position)<=_distance_squared:
		agent.use_flow_field = false
		agent.linear_damp = Constants.AGENT_MAX_LINEAR_DAMP
		return SUCCESS
	else:
		return RUNNING

