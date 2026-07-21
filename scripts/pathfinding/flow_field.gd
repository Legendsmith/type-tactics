class_name FlowField

signal field_ready

const allow_diagonals:= true

var field: Dictionary[Vector2i,float]
var tile_size:int = 16
var tile_map: TileMapLayer
var origin: Vector2i
var size: Vector2i
var rect: Rect2i
var flow_field_ready:bool=false

func _init(_tile_map: TileMapLayer, _size: Vector2i= Vector2i.ZERO):
	tile_map= _tile_map
	size= _size

func build(_origin: Vector2i):
	origin= _origin

	field.clear()
	
	if size:
		rect= Rect2i(origin - Vector2i(size.x, size.y) / 2, Vector2i(size.x, size.y))
	else:
		rect= tile_map.get_used_rect()

	# start the flow field from the origin with a value of 0
	var active_points: Array[Vector2i]= []
	active_points.append(origin)
	field[origin]= 0.0
	
	while not active_points.is_empty():
		# for each active point add all neighbor grid positions to the active points list,
		# that are inside the rect, arent part of the flow field yet and arent an obstacle
		
		var active_point: Vector2i= active_points[0]
		for x in range(-1, 2):
			for y in range(-1, 2):
				if x == 0 and y == 0: continue
				if x == 0 or y == 0 or allow_diagonals:
					var point:= Vector2i(x, y)
					point+= active_points[0]
					if rect.has_point(point):
						var cell:TileData = tile_map.get_cell_tile_data(point)
						if cell and cell.has_custom_data("flow_cost"):
							var flow_cost:float = cell.get_custom_data("flow_cost")
							if flow_cost > 0:
								if not field.has(point):
									active_points.append(point)
									# the new point has a value of the current point + 1
									field[point]= field[active_point] + sqrt(abs(x) + abs(y)) + flow_cost * point.distance_to(origin)
								else:
									# if this point is already part of the flow field choose
									# the lowest value
									field[point]= min(field[point], field[active_point] + sqrt(abs(x) + abs(y))) + flow_cost * point.distance_to(origin)
								
		# remove this point from the active points list
		active_points.remove_at(0)


func get_grid_coords(pos: Vector2)-> Vector2i:
	return tile_map.local_to_map(pos)


func debug_draw(canvas: CanvasItem, _tile_map: TileMapLayer,offset:Vector2):
	for key: Vector2i in field:
		var center:= _tile_map.map_to_local(key)
		canvas.draw_string(load("uid://iydw2xhpferi"), (center+offset)-Vector2(_tile_map.tile_set.tile_size)/2, "%.1f" % field[key], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.CYAN)


func get_move_multiplier(from:Vector2i) -> float:
	if rect.has_point(from):
		var cell:TileData = tile_map.get_cell_tile_data(from)
		if cell:
			return cell.get_custom_data("flow_cost")
		else:
			return 0.3
	else:
		return 0.3
