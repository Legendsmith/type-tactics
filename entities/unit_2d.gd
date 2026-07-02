extends Node2D
var grid:TileMapLayer
var display_name:String:
	get:
		return $Unit.display_name
@export var unit:Unit

func _ready() -> void:
	if not is_instance_valid(grid):
		if get_parent() is TileMapLayer:
			grid = get_parent()
	if not is_instance_valid(unit):
		unit = find_child("Unit",false)
	$Sprite2D.texture = unit.battle_sprite
	if global_position.y > 0:
		$Sprite2D.frame = 1
	position = grid.map_to_local(get_grid_position())

func get_grid_position() -> Vector2i:
	return grid.local_to_map(grid.to_local(global_position))
