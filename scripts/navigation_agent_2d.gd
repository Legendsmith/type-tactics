extends NavigationAgent2D
@export var velocity_mod_threshold:float = 10
@export var velocity_ease:float = 0.5
@onready var agent:Node2D = get_parent()

const MAX_LINEAR_DAMP:float = 4.0

var use_flow_field=false
var flow_field:FlowField
const TURN_SPEED_FLOOR_COEFFICIENT:float = 0.1

func _ready():
	velocity_computed.connect(on_velocity_computed)
	process_mode = PROCESS_MODE_DISABLED
	debug_path_custom_color = Color(randf_range(0.2,1),randf_range(0.2,1),randf_range(0.2,1))

func activate(position:Vector2):
	#agent.linear_damp = agent.linear_damp_max*0.1 # Set damp low so the agent can move well.
	process_mode = PROCESS_MODE_INHERIT
	target_position = position
	use_flow_field=false
	get_next_path_position()
	#print_debug("Activate pathfinding for ", agent.name)

func activate_flow_field(position:Vector2,target_flow_field:FlowField):
	flow_field = target_flow_field
	if not flow_field.flow_field_ready:
		await flow_field.field_ready
	target_position = position
	process_mode = PROCESS_MODE_INHERIT
	flow_field = target_flow_field
	use_flow_field = true
	get_next_path_position()

func _physics_process(_delta: float) -> void:
	if is_navigation_finished() or is_target_reached():
		finish()
	elif follow_flow_field():
		if agent.desired_velocity.is_zero_approx():
			pathfind()
	else:
		pathfind()
		#agent.linear_damp = move_toward(agent.linear_damp,Agent.MIN_LINEAR_DAMP,agent.takeoff_time * delta)
		agent.move(agent.desired_velocity)

func pathfind():
	var next_pos = get_next_path_position()
	## what's the angle difference between our move and the direction and direction to next target.
	var desired_velocity: Vector2 = agent.global_position.direction_to(next_pos) * min(distance_to_target(),max_speed)
	if avoidance_enabled:
		set_velocity(desired_velocity)
	else:
		agent.desired_velocity = desired_velocity


func on_velocity_computed(safe_velocity:Vector2):
	agent.desired_velocity = safe_velocity

func finish():
		#agent.think() # call the behaviour tree when we're done.
		#agent.linear_damp = agent.linear_damp_max
		process_mode = PROCESS_MODE_DISABLED
		agent.desired_velocity = Vector2.ZERO 
		#print_debug("finished pathfinding")

func follow_flow_field() -> bool:
	if use_flow_field:
		var dir=flow_field.get_direction(agent.global_position)
		if dir == Vector2.ZERO:
			return false
		agent.desired_velocity = dir * min(distance_to_target(),max_speed)
		agent.linear_damp = MAX_LINEAR_DAMP * flow_field.get_move_multiplier(flow_field.get_grid_coords(agent.global_position))
		agent.move(dir * min(distance_to_target(),max_speed))
		return true
	else:
		return false
