extends Node
@warning_ignore_start("unused_signal")

const SPATIAL_HASH_SIZE = Constants.SPATIAL_HASH_SIZE

signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
# Used to activate entities near this part of the map, usually when the player approaches.
signal activate_grid(coordinates:Vector2i)
signal request_astar_links()
signal request_hashmap_tilemap(requester:Node)

var astar:AStar2D = AStar2D.new()
var last_astar_id:int = 0

func _ready() -> void:
	pass

func reset_map():
	astar = AStar2D.new()

## Creates
func register_astar_point(coordinates:Vector2) -> int:
	var hash_position:Vector2i = Vector2i(coordinates/SPATIAL_HASH_SIZE)
	var closest_existing_id:int = astar.get_closest_point(hash_position)
	## Check if this point is already in the compressed map, return the id if it is.
	if Vector2i(astar.get_point_position(closest_existing_id)) == hash_position:
		return closest_existing_id
	else: #If it's not create a new one and 
		var point_id:int = astar.get_available_point_id()
		astar.add_point(point_id,hash_position,1)
		last_astar_id = point_id
		return point_id

func register_astar_link(from:Vector2,to:Vector2,bidirectional:bool=false)->int:
	var from_id:int = astar.get_closest_point(Vector2i(from/SPATIAL_HASH_SIZE))
	var destination_id:int = astar.get_closest_point(Vector2i(to/SPATIAL_HASH_SIZE))
	astar.connect_points(from_id,destination_id,bidirectional)
	return destination_id

func on_player_hash_location_changed(location:Vector2i):
	activate_grid.emit(location)
