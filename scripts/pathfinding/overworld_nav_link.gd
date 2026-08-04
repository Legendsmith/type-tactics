extends NavigationLink2D
var astar_start_id:int
var astar_end_id:int


func _ready() -> void:
	SpatialMap.request_astar_links.connect(on_request_astar_links)

func on_request_astar_links():
	astar_start_id = SpatialMap.register_astar_point(start_position)
	astar_end_id = SpatialMap.register_astar_link(
		to_global(start_position),
		to_global(end_position),
		bidirectional
	)

