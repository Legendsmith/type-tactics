class_name Overworld
extends MainScene2D

@export var player_faction_goal:Node2D
@export var enemy_faction_goal:Node2D

func _ready() -> void:
	SpatialMap.request_astar_links.emit()
	SpatialMap.activate_flow_path.emit(Constants.PLAYER_GROUP,Vector2i(player_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	SpatialMap.activate_flow_path.emit(Constants.ENEMY_GROUP,Vector2i(enemy_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
