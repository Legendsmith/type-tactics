extends NavigationAgent2D
@export var velocity_mod_threshold:float = 10
@export var velocity_ease:float = 0.5
@onready var agent:Node2D = get_parent()

const MAX_LINEAR_DAMP := Constants.AGENT_MAX_LINEAR_DAMP


const TURN_SPEED_FLOOR_COEFFICIENT:float = 0.1

func _ready():
	velocity_computed.connect(on_velocity_computed)
	process_mode = PROCESS_MODE_DISABLED
	set_physics_process(false)
	debug_path_custom_color = Color(randf_range(0.2,1),randf_range(0.2,1),randf_range(0.2,1))

func activate(position:Vector2):
	#agent.linear_damp = agent.linear_damp_max*0.1 # Set damp low so the agent can move well.
	process_mode = PROCESS_MODE_INHERIT
	agent.linear_damp = 1
	set_physics_process(true)
	target_position = position
	agent.use_flow_field=false
	get_next_path_position()
	#print_debug("Activate pathfinding for ", agent.name)


func _physics_process(_delta: float) -> void:
	if is_navigation_finished():
		finish()
	elif (Engine.get_physics_frames() + agent.tick_offset) % (agent.skip_frames + 1) == 0:
		pathfind()
		agent.move(agent.desired_velocity)
		agent.animation_player.play("move_"+str(OverworldAgent.get_direction_index(agent.desired_velocity)),-1,agent.desired_velocity.length_squared()/(max_speed*max_speed))
		#agent.linear_damp = move_toward(agent.linear_damp,Agent.MIN_LINEAR_DAMP,agent.takeoff_time * delta)

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
	agent.animation_player.play("idle_"+str(OverworldAgent.get_direction_index(agent.desired_velocity)))
	agent.think() # call the behaviour tree when we're done.
	agent.linear_damp = 16
	process_mode = PROCESS_MODE_DISABLED
	set_physics_process(false)
	agent.desired_velocity = Vector2.ZERO 
	#print_debug("finished pathfinding")
