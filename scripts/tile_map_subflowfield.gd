extends TileMapLayer

var flow_field_x:FlowField
var flow_field_y:FlowField
var hash_location:Vector2i
## direction
var connections:Dictionary[Vector2i,PackedVector2Array]
var global_hashmap_connections:Array[Vector2i]
var avg_flow_cost:float = 0


func _ready() -> void:
	hash_location = Vector2i(global_position / Constants.SPATIAL_HASH_SIZE)
	SpatialMap.map[hash_location] = self
	generate_directions()
	SpatialMap.link_request.connect(connect_link)
	process_mode = Node.PROCESS_MODE_DISABLED



func connect_link(link:Node2D,coordinates_start:Vector2,coordinates_end:Vector2):
	var local_start:Vector2 = to_local(coordinates_start)
	var local_end:Vector2 = to_local(coordinates_end)
	var local_coords:Vector2i
	var direction:Vector2i
	var destination:Vector2i
	if get_used_rect().has_point(local_start):
		local_coords = local_start
		destination = Vector2i(coordinates_end / Constants.SPATIAL_HASH_SIZE)
		direction = ((coordinates_start/Constants.SPATIAL_HASH_SIZE).direction_to(coordinates_end/ Constants.SPATIAL_HASH_SIZE)).snappedf(1)
	elif get_used_rect().has_point(local_end):
		local_coords = local_end
		destination = Vector2i(coordinates_start / Constants.SPATIAL_HASH_SIZE)
		direction = ((coordinates_end/Constants.SPATIAL_HASH_SIZE).direction_to(coordinates_start / Constants.SPATIAL_HASH_SIZE)).snappedf(1)
	else:
		return
	global_hashmap_connections.append(destination)
	connections.get_or_add(direction,PackedVector2Array([])).append(local_coords)




func generate_directions():
	flow_field_x = build(&"x",&"y")
	flow_field_y = build(&"y",&"x")


func build(direction:StringName,orthogonal:StringName):
	var field:Dictionary[Vector2i,float] = {}
	var rect:Rect2i = get_used_rect()
	# Get the lower right, this is the destination of the flowfield as it is positive X & Y.
	var origin = rect.end
	var active_points: Array[Vector2i]= []
	active_points.resize(origin[orthogonal])
	# build rightmost column
	for i:int in range(0,origin[orthogonal]):
		var point = Vector2i(rect.end[direction],i)
		var cell:TileData = get_cell_tile_data(point)
		if cell and cell.has_custom_data("flow_cost"):
			var flow_cost:float = cell.get_custom_data("flow_cost")
			if flow_cost > 0:
				active_points[i] = point
				field[point]=0.0

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
							var flow_cost:float = cell.get_custom_data("flow_cost")
							var distance_to_origin:float = abs(active_point[direction]-origin[direction])
							if flow_cost > 0 and not field.has(point):
								active_points.append(point)
								field[point]= field[active_point] + sqrt(abs(x) + abs(y)) + flow_cost * distance_to_origin
							elif flow_cost > 0:
								field[point]= min(field[point], field[active_point] + sqrt(abs(x) + abs(y))) + flow_cost * distance_to_origin
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

