extends BTAction
@export var position_var: StringName = &"pos"
@export var speed_var := &"speed"
@export var tolerance: float = 120.0


@export var avoid_var: StringName
## Specifies the node to avoid (valid Node2D is expected).
## If not empty, agent will circle around the node while moving into position.

var target_position: Vector2 = Vector2.ZERO
var _tolerance_sqrd

func _init():
	_tolerance_sqrd = pow(tolerance, 2)

func _enter() -> void:
	target_position = blackboard.get_var(position_var)

func _tick(_delta: float) -> Status:
	var speed = blackboard.get_var(speed_var,800.0)
	if agent.global_position.distance_squared_to(target_position) <= _tolerance_sqrd:
		agent.desired_velocity = Vector2.ZERO
		return SUCCESS
	var dir: Vector2 = agent.global_position.direction_to(target_position)
	if not avoid_var.is_empty():
		var avoid_node: Node2D = blackboard.get_var(avoid_var)
		if is_instance_valid(avoid_node):
			var distance_vector: Vector2 = avoid_node.global_position - agent.global_position
			if dir.dot(distance_vector) > 0.0:
				var side := dir.rotated(PI * 0.5).normalized()
				# The closer we are to the avoid target, the stronger is the avoidance.
				var strength: float = remap(distance_vector.length(), 200.0, 300.0, 1.0, 0.0)
				strength = clampf(strength, 0.0, 1.0)
				var avoidance := side * signf(-side.dot(distance_vector)) * strength
				dir += avoidance
	var desired_velocity: Vector2 = dir * speed
	agent.desired_velocity = desired_velocity
	#agent.turn(desired_velocity.angle())
	return RUNNING
