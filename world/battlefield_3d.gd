extends GridMap

var active_grid:Array[Vector3i]

func _ready() -> void:
	active_grid = get_used_cells()
