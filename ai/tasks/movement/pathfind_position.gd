@tool
extends BTAction
@export var position_var:StringName = &"pos"
@export var use_avoidance:bool = true
@export var speed_var:StringName = &"speed"
@export var target_distance_var:StringName = &"distance"
@export var approach_distance_default: float = 16.0
@export var nav_agent: NodePath
@export var continuous_update:bool = false
var target_position: Vector2
var _nav_agent: NavigationAgent2D
var _distance_squared:float 

func _generate_name() -> String:
	return "Pathfind to %s, at %s" % [
		LimboUtility.decorate_var(position_var),LimboUtility.decorate_var(target_distance_var)]

func _enter() -> void:
	var distance:float = blackboard.get_var(target_distance_var, approach_distance_default, false)
	_distance_squared = distance * distance
	_nav_agent.avoidance_enabled = use_avoidance
	_nav_agent.target_desired_distance = distance
	activate_nav_agent()

func _setup() -> void:
	_nav_agent = agent.get_node(nav_agent)

func _tick(_delta: float) -> Status:
	if continuous_update:
		_nav_agent.activate_nav_agent()
	if _nav_agent.is_navigation_finished() or agent.global_position.distance_squared_to(target_position) <= _distance_squared:
		return SUCCESS
	elif _nav_agent.process_mode != Node2D.PROCESS_MODE_INHERIT:
		print_debug("Path failed, nav agent inactive")
		return FAILURE
	elif _nav_agent.is_target_reachable():
		return RUNNING
	else:
		print_debug("Path failed, target unreachable.")
		return FAILURE

func activate_nav_agent():
	var pos:Vector2 = blackboard.get_var(position_var)
	target_position = pos
	_nav_agent.max_speed = blackboard.get_var(speed_var,agent.speed)
	_nav_agent.activate(target_position)
