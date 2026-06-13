@tool
extends Polygon2D
const COLOR_VARIANCE:float = 0.1
@export var terrain_set:int = 0
@export_enum("White","Dirt","Sand","Grass","Stone") var terrain:int = 0

func _ready():
	if get_parent() is TileMapLayer:
		if Engine.is_editor_hint():
			get_parent().tile_set.changed.connect(update_color)
		update_color()

	
	

func update_color():
	var parent:TileMapLayer = get_parent()
	color = parent.tile_set.get_terrain_color(terrain_set,terrain).darkened(randf_range(0,COLOR_VARIANCE))
