extends Node2D
var grid:TileMapLayer
func get_grid_position():
	return grid.local_to_grid(grid.to_local(global_position))
