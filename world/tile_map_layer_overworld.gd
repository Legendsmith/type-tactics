extends TileMapLayer


const MAX_RESULTS:int = 24
signal activate_link(faction:StringName,path:PackedVector2Array)
@onready var astar_point_id:int = SpatialMap.register_astar_point(global_position)
@onready var hash_rect:Rect2i = Rect2i(global_position / Constants.SPATIAL_HASH_SIZE,ceil((get_used_rect().size*tile_set.tile_size)/Constants.SPATIAL_HASH_SIZE)+Vector2i.ONE)
@onready var tick_offset:int = randi() % Engine.physics_ticks_per_second

func _ready() -> void:
	if get_used_rect().position < Vector2i.ZERO:
		push_warning("%s (Tile Map Layer Overworld) has tiles at negative coordinates, this will cause pathfinding problems" % name)
	#SpatialMap.update_timer.timeout.connect(update_traffic)
	process_mode = Node.PROCESS_MODE_DISABLED
	SpatialMap.activate_flow_path.connect(on_activate_flow_path)
	SpatialMap.request_map_point_id.connect(on_request_map_point_id)
	SpatialMap.hashmap_point_id.connect(on_hashmap_point_id)
	SpatialMap.request_tilemap.connect(on_request_tilemap)

func on_request_tilemap(requesting_node:Node,coordinates:Vector2i):
	if hash_rect.has_point(coordinates):
		requesting_node.tile_map = self

func on_hashmap_point_id(hash_object:SpatialHash):
	if hash_rect.has_point(hash_object.hash_location):
		hash_object.astar_point_id = astar_point_id

func on_request_map_point_id(node:Node,_position:Vector2i,property:StringName):
	if hash_rect.has_point(_position):
		node.set(property,astar_point_id)

#func update_traffic() -> void:
#	for i in range(tick_offset):
#		await get_tree().physics_frame
#	var accumulated
#	for x:int in range(hash_rect.size.x):
#		for y:int in range(hash_rect.size.y):
#			var results:Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(build_query(Vector2(x,y)*Constants.SPATIAL_HASH_SIZE),MAX_RESULTS)
#			var traffic_congestion_rating:float = ease(minf(results.size(),1), Constants.OVERWORLD_TRAFFIC_EASE)
#			SpatialMap.astar.set_point_weight_scale(astar_point_id,traffic_congestion_rating)
#			await get_tree().physics_frame
#

func on_activate_flow_path(faction:StringName,spatial_hash:Vector2i):
	var target_point_id:int = SpatialMap.astar.get_closest_point(spatial_hash)
	var path:PackedInt64Array = SpatialMap.astar.get_id_path(astar_point_id,target_point_id)
	activate_link.emit(faction,path)


func build_query(offset:Vector2=Vector2.ZERO):
	var q:PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	q.shape = load(Constants.OVERWORLD_PHYSICS_QUERY_SHAPE_RESOURCE)
	q.transform = Transform2D.IDENTITY.translated(global_position+offset)
	q.collision_mask = Factions.master_phys
	q.exclude = [get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).get_rid()] # need this so player ent won't get mind controlled
	return q
