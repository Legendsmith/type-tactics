@tool
class_name Battlefield
extends Node2D

enum Orientations {
	## Indicates that visual cells enumerate in the same direction as the tilemap layer
	LOW_TO_HIGH,
	## Indicates that visual cells enumerate in the opposite direction of the tilemap layer
	HIGH_TO_LOW,
}

const DEFAULT_TERRAIN: int = 0

@warning_ignore("unused_private_class_variable")
@export_tool_button("Redraw terrain") var _redraw_terrain_handler = redraw_terrain

## Sets the direction that files (columns, x) are oriented, by default they are oriented from left to right.
@export var file_orientation := Orientations.LOW_TO_HIGH
## Sets the direction that ranks (rows, y) are oriented, by default they are oriented from top to bottom.
@export var rank_orientation := Orientations.LOW_TO_HIGH
## Sets the dimension for the field
@export var dimensions: Vector2i = Vector2i(3, 3): set = set_dimensions

## The terrain tilemap layer used to create the ground
@onready var terrain_layer: TileMapLayer = $TerrainLayer

## The bitmap that keeps track if something occupies a given space.
var occupancy_map: BitMap = BitMap.new()

## Gets the center position of a given tile in local coordinate space.
func get_tile_center_local_position(file: int, rank: int) -> Vector2:
	var map_position: Vector2i = get_map_position(file, rank)
	
	return terrain_layer.map_to_local(map_position) + terrain_layer.position

## Gets the center position of a given tile in global coordinate space.
func get_tile_center_global_position(file: int, rank: int) -> Vector2:
	return get_tile_center_local_position(file, rank) + global_position

## returns the position of the native tilemap layer based on the given file and coordinates
func get_map_position(file: int, rank: int) -> Vector2i:
	#if file < 0 or file >= dimensions.x or rank < 0 or rank >= dimensions.y:
		#push_error("invalid coordinates, expected file and rank between [0 ... %d] and [0 ... %d] (inclusive) respectively." % [dimensions.x - 1, dimensions.y - 1])
	
	return Vector2i(
		file if file_orientation == Orientations.LOW_TO_HIGH else dimensions.x - file - 1, 
		rank if rank_orientation == Orientations.LOW_TO_HIGH else dimensions.y - rank - 1
	)

func set_tile_occupied(file: int, rank: int, state: bool) -> void:
	occupancy_map.set_bit(file, rank, state)

func is_tile_occupied(file: int, rank: int) -> bool:
	return occupancy_map.get_bit(file, rank)

func get_tile_custom_data(file: int, rank: int) -> Dictionary:
	var map_position: Vector2i = get_map_position(file, rank)
	var tile_data: TileData = terrain_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		push_error("could not find a tile at the given file and rank")
	
	return tile_data.get_custom_data("custom_data")

func set_tile_custom_data(file: int, rank: int, data: Dictionary) -> void:
	var map_position: Vector2i = get_map_position(file, rank)
	var tile_data: TileData = terrain_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		push_error("could not find a tile at the given file and rank")
	
	tile_data.set_custom_data("custom_data", data)

func get_tile_terrain_type(file: int, rank: int) -> int:
	var map_position: Vector2i = get_map_position(file, rank)
	var tile_data: TileData = terrain_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		push_error("could not find a tile at the given file and rank")
	
	return tile_data.terrain

func set_tile_terrain_type(file: int, rank: int, terrain_type: int) -> void:
	var map_position: Vector2i = get_map_position(file, rank)
	var tile_data: TileData = terrain_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		push_error("could not find a tile at the given file and rank")
	
	terrain_layer.set_cells_terrain_connect([map_position], 0, terrain_type)

## Sets the dimensions of the battlefield. The battlefield has a minimum size of 1 x 1 tiles.
func set_dimensions(value: Vector2i) -> void:
	dimensions = value.maxi(1)
	occupancy_map.resize(dimensions)
	redraw_terrain.call_deferred()

## Forces the terrain layer to be reconstructed based on it's current dimensions.
func redraw_terrain() -> void:
	if terrain_layer:
		if not terrain_layer.tile_set:
			push_warning("No tileset used in the terrain layer.")
			return
	else:
		return
	
	terrain_layer.clear()
	
	var cells: Array[Vector2i] = []
	for x in dimensions.x:
		for y in dimensions.y:
			cells.append(Vector2i(x, y))
	
	terrain_layer.set_cells_terrain_connect(cells, 0, DEFAULT_TERRAIN)
	
	const OFFSET : Vector2 = Vector2(0.25, 0.25)
	
	var used := terrain_layer.get_used_rect()
	
	var top_left := terrain_layer.map_to_local(used.position)
	var bottom_right := terrain_layer.map_to_local(used.position + used.size - Vector2i.ONE)
	bottom_right += terrain_layer.tile_set.tile_size * 0.5
	var center := (top_left + bottom_right) * 0.5
	
	terrain_layer.position = -center + (OFFSET * Vector2(terrain_layer.tile_set.tile_size))

func get_target_at_map_position(pos:Vector2i):
	var query:PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = get_tile_center_global_position(pos.x,pos.y)
	query.collision_mask = CombatMechanics.UNIT_LAYER
	var query_result = get_world_2d().direct_space_state.intersect_point(query)
	return query_result
