class_name AttackPatternResource
extends Resource

@export var offsets: Array[Vector2i] = []

func get_targeted_positions(target_position: Vector2i) -> Array[Vector2i]:
	var target_positions: Array[Vector2i] = offsets.duplicate()
	for index in target_positions.size():
		target_positions[index] = target_positions[index] + target_position
	
	return target_positions
