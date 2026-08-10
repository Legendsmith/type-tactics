extends Node
@warning_ignore_start("unused_signal")

const MAP_UPDATE_INTERVAL := 2.2
const SPATIAL_HASH_SIZE = Constants.SPATIAL_HASH_SIZE

signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
# Used to activate entities near this part of the map, usually when the player approaches.
signal activate_grid(coordinates:Vector2i,faction)
## Used to activate the astar links for this map
signal request_astar_links()
## Request the id of a location in the astar grid. Sets the property of the node to this. Can likely rework to use pointers so we don't need to use "set"
signal request_map_point_id(node:Node,position:Vector2i,property:StringName)
signal hashmap_point_id(hash_object:SpatialHash)
## What tilemap owns this hash coordinate?
signal request_tilemap(requester:Node,coordinates:Vector2i)
## Activate flowfields to this location.
signal activate_flow_path(faction:StringName,spatial_hash:Vector2i)
## Used by agents to get the appropriate flowfields for where they are.
signal agent_request_flow_field(agent:OverworldAgent,spatial_hash:Vector2i)
## Used to determine if a battle should occur by checking if everyone in a given location is the same faction. If not: Battle!
signal hashmap_faction_check(faction:Pointer.StringNamePtr,check:Pointer.BoolPtr,coordinates: Vector2i)

signal control_updated(coordinates:Vector2i,faction:StringName)

signal request_battle(location:Vector2i)

var astar:AStar2D = AStar2D.new()
var last_astar_id:int = 0
var update_timer:Timer

var control_map:Dictionary[Vector2i,StringName]
var dirty_control_map:bool = false
var control_map_update_ready:bool = true

func _ready() -> void:
	update_timer = Timer.new()
	update_timer.wait_time = MAP_UPDATE_INTERVAL
	update_timer.autostart = true
	add_child(update_timer)

func reset_map() -> void:
	astar = AStar2D.new()

## Creates
func register_astar_point(coordinates:Vector2) -> int:
	var hash_position:Vector2i = Vector2i(coordinates/SPATIAL_HASH_SIZE)
	var closest_existing_id:int = astar.get_closest_point(hash_position)
	## Check if this point is already in the compressed map, return the id if it is.
	if closest_existing_id != -1 and Vector2i(astar.get_point_position(closest_existing_id)) == hash_position:
		return closest_existing_id
	else: #If it's not create a new one
		var point_id:int = astar.get_available_point_id()
		astar.add_point(point_id,hash_position,1)
		last_astar_id = point_id
		return point_id

#func register_astar_link(from:Vector2,to:Vector2,bidirectional:bool=false)->int:
#	var from_id:int = astar.get_closest_point(Vector2i(from/SPATIAL_HASH_SIZE))
#	var destination_id:int = astar.get_closest_point(Vector2i(to/SPATIAL_HASH_SIZE))
#	astar.connect_points(from_id,destination_id,bidirectional)
#	return destination_id

func on_player_hash_location_changed(location:Vector2i) -> void:
	activate_grid.emit(location)

func flow_path_to_destination(faction:StringName, global_destination:Vector2) -> void:
	var hash_destination:Vector2i = Vector2i(global_destination/SPATIAL_HASH_SIZE)
	activate_flow_path.emit(faction,hash_destination)

func check_control() -> void:
	if dirty_control_map and control_map_update_ready:
		control_map_update_ready = false
		print_debug("Updating map")
		for coordinates:Vector2i in control_map:
			await get_tree().process_frame
			if control_map[coordinates] == &"updating":
				var result:Pointer.BoolPtr = Pointer.BoolPtr.new(true)
				var faction:Pointer.StringNamePtr = Pointer.StringNamePtr.new()
				hashmap_faction_check.emit(faction,result,coordinates)
				print_debug("Location: %s, Result: %s Faction: %s" % [coordinates,result.value,faction.value])
				# TODO: Put in some kind of notification for control change
				if not result.value:
					control_map[coordinates] = &"contested"
					request_battle.emit(coordinates)
				else:
					update_control(coordinates,faction.value)
		dirty_control_map = false
		control_map_update_ready = true

		
func update_control(coordinates:Vector2i,faction:StringName):
	control_map[coordinates] = faction
	control_updated.emit(coordinates,faction)
