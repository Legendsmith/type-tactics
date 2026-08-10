extends NavigationLink2D
var astar_start_id:int
var astar_end_id:int

var tile_map:TileMapLayer:
	set(new_tile_map):
		if tile_map:
			if tile_map.activate_link.is_connected(on_activate_link):
				tile_map.activate_link.disconnect(on_activate_link)
		tile_map = new_tile_map
		tile_map.activate_link.connect(on_activate_link)
		build_flow_field()
		
var flow_field:FlowField
var active_factions:Array[StringName] = []

#@onready var hash_location:Vector2i = Vector2i(to_global(start_position)/Constants.SPATIAL_HASH_SIZE)

func _ready() -> void:
	SpatialMap.request_tilemap.emit(self,Vector2i(to_global(start_position)/Constants.SPATIAL_HASH_SIZE))
	$StartArea.body_entered.connect(on_agent_enter)
	$StartArea.collision_mask = Factions.master_phys | (1 << Constants.PLAYER_PHYSICS_LAYER)
	SpatialMap.agent_request_flow_field.connect(on_agent_request_flow_field)
	SpatialMap.request_astar_links.connect(on_request_astar_links)
	

func on_activate_link(faction:StringName,path:PackedInt64Array) -> void:
	if astar_end_id in path and not faction in active_factions:
		active_factions.append(faction)
	else:
		active_factions.erase(faction)
	#update_area_mask()

# Updates the start area's collision mask to only detect units that desire entry.
#func update_area_mask():
#	var collision_mask:int = (1 << Constants.PLAYER_PHYSICS_LAYER)
#	for faction_name:StringName in active_factions:
#		collision_mask = collision_mask | Factions.faction_list[faction_name].physics_layer
#	$StartArea.collision_mask = collision_mask

## Usually called once, registers the link in the global astar map.
func on_request_astar_links():
	SpatialMap.request_map_point_id.emit(self,Vector2i(to_global(end_position)/Constants.SPATIAL_HASH_SIZE),&"astar_end_id")
	SpatialMap.astar.connect_points(astar_start_id,astar_end_id,bidirectional)

#builds the flow field towards it using its assigned tilemap.
func build_flow_field():
	var tile_size:Vector2 = tile_map.tile_set.tile_size
	position = position.snapped(tile_size)
	start_position = start_position.snapped(tile_size) #+ tile_size/2
	end_position = end_position.snapped(tile_size) #+ tile_size/2
	flow_field = DirectionFlowField.new(tile_map)
	flow_field.build(tile_map.local_to_map(tile_map.to_local(to_global(start_position))))
	configure_areas()


#Teleports the entering agent. Always teleports the player.
func on_agent_enter(body:Node2D):
	if body is OverworldPlayer or body.faction in active_factions or body.action == &"follow":
		OverworldAgent.teleport(body,$EndDestination.global_position)

func configure_areas():
	$StartArea.position = start_position
	$StartArea.reset_physics_interpolation()
	$EndDestination.position = end_position
	$StartArea.monitoring = true

func on_agent_request_flow_field(agent:OverworldAgent,spatial_hash:Vector2i):
	if agent.faction in active_factions and tile_map.hash_rect.has_point(spatial_hash):
		agent.flow_field = flow_field
	
