extends "input_state.gd"
var animation:String = "idle_"
var deceleration_damp:float = 16
func _setup():
	named(&"IdleState")
func _enter() -> void:
	agent.linear_damp = deceleration_damp

func _update(delta: float) -> void:
	super(delta)
	#var target_point:Vector2 = agent.get_local_mouse_position()
	#agent.animation_player.play(animation+str(OverworldAgent.get_direction_index(target_point)))
	if agent.desired_velocity:
		dispatch(&"move")
