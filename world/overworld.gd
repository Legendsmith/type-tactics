class_name Overworld
extends MainScene2D

@export var player_unit_def:UnitDef
@export var player_faction_goal:Node2D
@export var enemy_faction_goal:Node2D

var battle_script_location:String = "uid://cfqrbe5b87mbm"

var battles:Dictionary[Vector2i,Area2D]

func _ready() -> void:
	if player_unit_def and get_tree().get_node_count_in_group(Constants.PLAYER_ENTITY): # If we're passed a unit definition for the player, load it.
		get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).load_unit_definition(player_unit_def)
	SpatialMap.request_astar_links.emit()
	SpatialMap.activate_flow_path.emit(Constants.PLAYER_GROUP,Vector2i(player_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	SpatialMap.activate_flow_path.emit(Constants.ENEMY_GROUP,Vector2i(enemy_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	super()
	SpatialMap.request_battle.connect(battle_check)
	

func battle_check(coordinates:Vector2i):
	var global_location:Vector2 = Vector2(coordinates * Constants.SPATIAL_HASH_SIZE)
	if not coordinates in battles.keys():
		#build_query(global_location)
		var new_battle:Area2D = Area2D.new()
		new_battle.set_script(load(battle_script_location))
		new_battle.global_position = global_location
		add_child(new_battle)
		battles[coordinates]=new_battle

#func build_query(key:StringName,location:Vector2):
#	var faction:Factions.Faction = Factions.faction_list[key]
#	var q:PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
#	q.shape = load(Constants.OVERWORLD_PHYSICS_QUERY_SHAPE_RESOURCE)
#	q.transform = Transform2D.IDENTITY.translated(location)
#	q.collision_mask = Factions.master_phys & faction.physics_layer
#	q.exclude = [get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).get_rid()] # need this so player ent won't get mind controlled
#	return q
