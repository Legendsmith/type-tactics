extends Area3D
func get_grid_position():
	return get_parent().local_to_map(position)
