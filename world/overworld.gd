class_name Overworld
extends MainScene2D

signal player_battle(opponent)

@export var player_unit_def:UnitDef
@export var player_faction_goal:Node2D
@export var enemy_faction_goal:Node2D

var battle_script_location:String = "uid://cfqrbe5b87mbm"
var player_battle_scene:String = "uid://gwsvkadrrijx"

var battles:Dictionary[Vector2i,Area2D]
var battle_stage:MainScene2D


func _ready() -> void:
	if player_unit_def and get_tree().get_node_count_in_group(Constants.PLAYER_ENTITY): # If we're passed a unit definition for the player, load it.
		get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).load_unit_definition(player_unit_def)
	SpatialMap.request_astar_links.emit()
	SpatialMap.activate_flow_path.emit(Constants.PLAYER_GROUP,Vector2i(player_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	SpatialMap.activate_flow_path.emit(Constants.ENEMY_GROUP,Vector2i(enemy_faction_goal.global_position/Constants.SPATIAL_HASH_SIZE))
	super()
	SpatialMap.request_battle.connect(npc_battle_check)
	initalize_player_battle_scene()
	

func initalize_player_battle_scene():
	battle_stage = load(player_battle_scene).instantiate()
	get_tree().root.add_child(battle_stage)
	battle_stage.process_mode = PROCESS_MODE_DISABLED
	battle_stage.visible=false
	tree_exiting.connect(battle_stage.queue_free) # connect the exit of the battle stage to this node.
	battle_stage.battle_over.connect(on_battle_over)


func npc_battle_check(coordinates:Vector2i):
	var global_location:Vector2 = Vector2(coordinates * Constants.SPATIAL_HASH_SIZE)
	if not coordinates in battles.keys():
		#build_query(global_location)
		var new_battle:Area2D = Area2D.new()
		new_battle.set_script(load(battle_script_location))
		new_battle.global_position = global_location
		add_child(new_battle)
		battles[coordinates]=new_battle


func begin_player_battle(opponent:OverworldAgent)->MainScene2D:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	player_battle.emit(opponent)
	return battle_stage


func on_battle_over(_winner:StringName):
	# TODO, add some kind of transition.
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
