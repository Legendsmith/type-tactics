class_name Overworld
extends MainScene2D

@export var player_faction_goal:Node2D
@export var enemy_faction_goal:Node2D

func _ready() -> void:
	SpatialMap.request_astar_links.emit()

