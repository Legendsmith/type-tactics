@tool
extends BTAction
@export var position_var:StringName = &"pos"
@export var use_avoidance:bool = true
@export var speed_var:StringName = &"speed"
@export var target_distance_var:StringName = &"distance"
@export var approach_distance_default: float = 16.0
@export var nav_agent: NodePath

var target_position: Vector2
var _nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Pathfind to %s, at %s" % [
		LimboUtility.decorate_var(position_var),LimboUtility.decorate_var(target_distance_var)]

func _enter() -> void:
	_nav_agent.avoidance_enabled = use_avoidance
	var pos:Vector2 = blackboard.get_var(position_var)
	target_position = pos
	var distance:float = blackboard.get_var(target_distance_var, approach_distance_default, false)
	_nav_agent.target_desired_distance = distance
	_nav_agent.max_speed = blackboard.get_var(speed_var,agent.max_speed)
	_nav_agent.activate(target_position)
	#if agent.global_position.distance_squared_to(target_position) > distance * distance:
	#	_nav_agent.activate(target_position)
	#else:
	#	print_debug("Didn't start nav agent.")

func _setup() -> void:
	_nav_agent = agent.get_node(nav_agent)

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
