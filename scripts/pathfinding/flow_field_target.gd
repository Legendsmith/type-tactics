extends Marker2D

#@export var field_size:Vector2i = Vector2i(100,100)
@export var debug_draw:bool = false:
	set(new):
		debug_draw=new
		queue_redraw()

var flow_field:FlowField
var flow_field_ready:bool = false

func _ready() -> void:
	if get_parent() is TileMapLayer:
		add_to_group(Constants.FLOW_FIELD_GROUP)
		var tile_map:TileMapLayer = get_parent()
		flow_field = DirectionFlowField.new(tile_map)
		flow_field.tile_size = tile_map.tile_set.tile_size.x
		flow_field.build(tile_map.local_to_map(position))
		if debug_draw:
			queue_redraw()


func get_flow_field_direction(from: Vector2)-> Vector2:
	if flow_field.rect.has_point(get_grid_coords(from)):
		return flow_field.get_direction(from)
	return Vector2.ZERO


func get_grid_coords(pos: Vector2)-> Vector2i:
	return flow_field.get_grid_coords(pos)


func get_direction(from: Vector2)-> Vector2:
	var dir: Vector2= get_flow_field_direction(from)
	return dir


func _draw() -> void:
	if debug_draw:
		flow_field.debug_draw(self,get_parent(),-position)
