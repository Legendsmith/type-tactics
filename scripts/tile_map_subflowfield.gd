extends TileMapLayer

var direction_flowfields:Dictionary[Vector2i,FlowField]
var hash_location:Vector2i
## direction
var connections:Dictionary[Vector2i,Vector2i]
var global_hashmap_connections:Array[Vector2i]
var avg_flow_cost:float = 0
var astar_point_id:int

func _ready() -> void:
	hash_location = Vector2i(global_position / Constants.SPATIAL_HASH_SIZE)
	SpatialMap.map[hash_location] = self
	generate_directions()
	var astar_point_id = SpatialMap.register_astar_point(global_position)
	process_mode = Node.PROCESS_MODE_DISABLED


func generate_directions():
	pass
	


func build(direction:Vector2i):
	var field:Dictionary[Vector2i,float] = {}
	var rect:Rect2i = get_used_rect()
	# Get the lower right, this is the destination of the flowfield as it is positive X & Y.
	var active_points: Array[Vector2i]= []
	var origins:Array[Vector2i]
	for link_position:Vector2 in connections[direction]:
		var point:Vector2i = local_to_map(link_position)
		active_points.append(point)
		field[point] = 0.0

	while not active_points.is_empty():
		# Remove this point from the active point list.
		var active_point:Vector2i = active_points.pop_front()
		for x in range(-1,2):
			for y in range(-1,2):
				if x == 0 and y == 0: continue
				if x == 0 or y == 0:
					var point:= Vector2i(x, y)
					point += active_point
					if rect.has_point(point):
						var cell:TileData = get_cell_tile_data(point)
						if cell and cell.has_custom_data("flow_cost"):
							#var flow_cost:float = cell.get_custom_data("flow_cost")
							#var distance_to_origin:float = abs(active_point[direction]-origin[direction])
							if flow_cost > 0 and not field.has(point):
								active_points.append(point)
								field[point]= field[active_point] + sqrt(abs(x) + abs(y))
							elif flow_cost > 0:
								field[point]= min(field[point], field[active_point] + sqrt(abs(x) + abs(y)))
	return field



func get_direction_flowfield(direction:Vector2):
	match direction:
		Vector2.RIGHT:
			return flow_field_x
		Vector2.LEFT:
			return flow_field_x
		Vector2.UP:
			return flow_field_y
		Vector2.DOWN:
			return flow_field_y

