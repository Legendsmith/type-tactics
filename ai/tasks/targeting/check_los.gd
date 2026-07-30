extends BTAction
## The target the agent will try to see.
@export var target_var:StringName = &"target"
## Set this variable to the collider it hits.
@export var output_var:StringName = &"target"
## Records the  location of the target to this variable.
@export var position_var:StringName = &"target_pos"
var query:PhysicsRayQueryParameters2D
func _setup() -> void:
	query = PhysicsRayQueryParameters2D.create(Vector2.ZERO, Vector2.ONE, agent.collision_mask)
	query.collide_with_areas = false
	#print_debug(_raycast.collision_mask)


func _tick(_delta: float) -> Status:
	var target:Node2D = blackboard.get_var(target_var,null)
	if not is_instance_valid(target):
		return FAILURE
	query.from = agent.global_position
	query.to = target.global_position
	var result:Dictionary = agent.get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		blackboard.set_var(position_var,result.position)
		if result.collider.get(&"faction") == target.faction or result.collider == target:
			blackboard.set_var(output_var,result.collider)
			return SUCCESS
		else:
			return FAILURE
	else:
		return FAILURE
