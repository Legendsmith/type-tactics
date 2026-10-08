extends Marker2D

#@export var field_size:Vector2i = Vector2i(100,100)
@export var debug_draw:bool = false:
	set(new):
		debug_draw=new
		queue_redraw()
@export var goal_faction_name:StringName = Constants.PLAYER_GROUP
var flow_field:FlowField
var tile_map:TileMapLayer:
	set = set_tile_map

func _ready() -> void:
	SpatialMap.agent_request_flow_field.connect(on_agent_request_flow_field)
	add_to_group(Constants.FLOW_FIELD_GROUP)
	await get_tree().physics_frame
	SpatialMap.request_tilemap.emit(self, Vector2i(global_position/Constants.SPATIAL_HASH_SIZE))

func get_flow_field_direction(from: Vector2)-> Vector2:
	if flow_field.rect.has_point(get_grid_coords(from)):
		return flow_field.get_direction(from)
	return Vector2.ZERO


func set_tile_map(new_tile_map:TileMapLayer):
	tile_map = new_tile_map
	flow_field = DirectionFlowField.new(tile_map)
	flow_field.tile_size = tile_map.tile_set.tile_size.x
	var tilemap_position:Vector2i= tile_map.local_to_map(tile_map.to_local(global_position))
	flow_field.build(tilemap_position)

func get_grid_coords(pos: Vector2)-> Vector2i:
	return flow_field.get_grid_coords(pos)


func get_direction(from: Vector2)-> Vector2:
	var dir: Vector2= get_flow_field_direction(from)
	return dir


func _draw() -> void:
	if debug_draw and is_instance_valid(tile_map):
		flow_field.debug_draw(self,tile_map,tile_map.global_position-global_position)

func on_agent_request_flow_field(agent:OverworldAgent,spatial_hash:Vector2i):
	if agent.target == self and tile_map.hash_rect.has_point(spatial_hash):
		agent.flow_field = flow_field
	
