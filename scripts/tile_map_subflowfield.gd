extends TileMapLayer

var flow_field_x:FlowField
var flow_field_y:FlowField
var hash_location:Vector2i
var connections_right:Array[Vector2i]
var connections_down:Array[Vector2i]
var connections_left:Array[Vector2i]
var connections_up:Array[Vector2i]
var avg_flow_cost:float = 0

func get_connections(direction:Vector2i)->Array[Vector2i]:
	match direction:
		Vector2i.RIGHT:
			return connections_right
		Vector2i.DOWN:
			return connections_down
		Vector2i.LEFT:
			return connections_left
		Vector2i.UP:
			return connections_up
		_:
			return []


func _ready() -> void:
	hash_location = Vector2i(global_position / Constants.SPATIAL_HASH_SIZE)
	SpatialMap.map[hash_location] = self
	generate_directions()
	build_connections()
	process_mode = Node.PROCESS_MODE_DISABLED


func generate_directions():
	flow_field_x = build(&"x",&"y")
	flow_field_y = build(&"y",&"x")


func build_connections():
	var rect:Rect2i = get_used_rect()
	connections_right = build_edge(Vector2i(rect.end.x,0),Vector2i.DOWN,rect.size.y) # take the end (rightmost) column and iterate down i
	connections_down = build_edge(Vector2i(0,rect.end.y,),Vector2i.RIGHT,rect.size.x)
	connections_left = build_edge(rect.position,Vector2i.DOWN,rect.size.y)
	connections_up = build_edge(rect.position,Vector2i.RIGHT,rect.size.x)

## Check if two of these tilemaplayers share a pathable point.
func check_connections(with:TileMapLayer,direction:Vector2i) -> Array[Vector2i]:
	var connections:Array[Vector2i] = []
	var with_edge:Array[Vector2i] = with.get_connections(direction * -1) # flip the direction.
	# Check if there's even a direction there. If either array is empty, there's no common direction.
	if  not get_connections(direction).size() or not with_edge.size():
		return []
	# if the highest n is less than the least n, there's no connection. Uses abs direction to zero the nonrelevant x/y component.
	if get_connections(direction).back() * direction.abs() > with_edge.front() * direction.abs():
		for point:Vector2i in get_connections(direction):
			if point in with_edge:
				connections.append(point)
		return connections
	else:
		return []


func build_edge(start:Vector2i,direction:Vector2i,dimension_size:int)->Array[Vector2i]:
	var edge_array:Array[Vector2i] = []
	for i:int in range(0,dimension_size):
		var point = (direction * i) + start # get the point by multiplying the direction vector by the step.
		var cell:TileData = get_cell_tile_data(point)
		if cell and cell.has_custom_data("flow_cost"):
			var flow_cost:float = cell.get_custom_data("flow_cost")
			if flow_cost > 0:
				edge_array.append(point)
	return edge_array


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

