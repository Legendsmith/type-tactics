extends Node2D

signal finalize_turn
signal new_turn

@export_custom(0,"scene") var interface_scene:String

var turn_ready:bool = false

func _ready():
	configure_interface()
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func configure_interface():
	var interface:Control = load(interface_scene).instantiate()
	GameManager.game_interface = interface
	GameManager.add_child(interface)
