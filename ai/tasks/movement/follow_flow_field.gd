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

## The agent's NavigationAgent2D
@export var nav_agent: NodePath

## How close should the agent be to the target position to return SUCCESS.
@export var tolerance := 32.0

var target_position: Vector2
var _nav_agent: NavigationAgent2D

func _setup() -> void:
	_nav_agent = agent.get_node(nav_agent)

func _generate_name() -> String:
	return "Follow Flow Field"

func _enter() -> void:
	var target:Node2D = blackboard.get_var(target_var)
	assert(target.is_in_group(Constants.FLOW_FIELD_GROUP),"Target %s is not in Flow Field group for Follow Flowfield action in agent %s!" % [target,agent])
	target_position = target.global_position
	blackboard.set_var(&"pos",target_position)
	_nav_agent.target_desired_distance = approach_distance_default
	_nav_agent.max_speed = blackboard.get_var(speed_var,agent.max_speed)
	_nav_agent.activate_flow_field(target_position,target.flow_field)

func _tick(_delta: float) -> Status:
	if _nav_agent.is_navigation_finished():
		return SUCCESS
	elif _nav_agent.process_mode != Node2D.PROCESS_MODE_INHERIT:
		print_debug("Path failed, nav agent inactive")
		return FAILURE
	elif _nav_agent.is_target_reachable():
		return RUNNING
	else:
		print_debug("Path failed, target unreachable.")
		return FAILURE
