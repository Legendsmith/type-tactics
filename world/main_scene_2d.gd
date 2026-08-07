class_name MainScene2D
extends Node2D

@export var background_music:AudioStream
@export_custom(0,"scene") var interface_scene:String

func _ready():
	configure_interface()
	if background_music:
		GameManager.play_music(background_music)

func configure_interface():
	var interface:Control = load(interface_scene).instantiate()
	GameManager.game_interface = interface
	GameManager.add_child(interface)
