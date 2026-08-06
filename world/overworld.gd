class_name Overworld
extends MainScene2D

@export var player_unit_def:UnitDef
@export var player_faction_goal:Node2D
@export var enemy_faction_goal:Node2D

func _ready() -> void:
	if player_unit_def and get_tree().get_node_count_in_group(Constants.PLAYER_ENTITY): # If we're passed a unit definition for the player, load it.
		get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).load_unit_definition(player_unit_def)
	SpatialMap.request_astar_links.emit()
	SpatialMap.activate_flow_path.emit(Constants.PLAYER_GROUP,Vector2i(player_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	SpatialMap.activate_flow_path.emit(Constants.ENEMY_GROUP,Vector2i(enemy_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	super()
	
