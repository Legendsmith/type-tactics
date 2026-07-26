extends "input_state.gd"
var animation:String = "move_"
var acceleration:float = 16

func _setup():
	named(&"MoveState")

func _enter() -> void:
	agent.linear_damp = 1

func _update(delta: float) -> void:
	super(delta)
	var target_speed = blackboard.get_var(&"speed")
	#print_debug(agent.linear_velocity.length()/target_speed)
	if agent.desired_velocity:
		agent.move(agent.desired_velocity * target_speed,delta)
		#agent.linear_velocity = agent.desired_velocity * target_speed
		#agent.move(agent.desired_velocity * target_speed,delta * acceleration)
		agent.animation_player.play(animation+str(Constants.get_direction_index(agent.desired_velocity)))
	else:
		dispatch(EVENT_FINISHED)
