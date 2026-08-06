extends TileMapLayer



signal activate_link(faction:StringName,path:PackedVector2Array)

@onready var hash_location:Vector2i = Vector2i(global_position / Constants.SPATIAL_HASH_SIZE)
@onready var tick_offset:int = randi() % Engine.physics_ticks_per_second
var astar_point_id:int = SpatialMap.register_astar_point(global_position)

func _ready() -> void:
	SpatialMap.update_timer.timeout.connect(update_traffic)
	process_mode = Node.PROCESS_MODE_DISABLED
	SpatialMap.activate_flow_path.connect(on_activate_flow_path)
	SpatialMap.request_tilemap.connect(on_request_tilemap)

func on_request_tilemap(requesting_node:Node,coordinates:Vector2i):
	if coordinates == hash_location:
		#print_debug("%s requested by %s at %s" % [name,requesting_node.name,coordinates])
		requesting_node.tile_map = self


func update_traffic() -> void:
	for i in range(tick_offset):
		await get_tree().physics_frame
	var results:Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(build_query())
	var traffic_congestion_rating:float = ease(minf(results.size(),1), Constants.OVERWORLD_TRAFFIC_EASE)
	SpatialMap.astar.set_point_weight_scale(astar_point_id,traffic_congestion_rating)

#This isn't the most efficient since every tilemap will call it but it should be fine, probably.
func on_activate_flow_path(faction:StringName,spatial_hash:Vector2i):
	var target_point_id:int = SpatialMap.astar.get_closest_point(spatial_hash)
	var path:PackedInt64Array = SpatialMap.astar.get_id_path(astar_point_id,target_point_id)
	activate_link.emit(faction,path)


func build_query():
	var q:PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	q.shape = load(Constants.OVERWORLD_PHYSICS_QUERY_SHAPE_RESOURCE)
	q.transform = Transform2D.IDENTITY.translated(self.global_position)
	q.collision_mask = Factions.master_phys
	q.exclude = [get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).get_rid()] # need this so player ent won't get mind controlled
	return q
