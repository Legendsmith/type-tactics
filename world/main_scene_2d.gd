class_name MainScene2D
extends Node2D
@export var input_mapping_context:GUIDEMappingContext
@export var background_music:AudioStream
@export_custom(0,"scene") var interface_scene:String

func _ready():
	configure_interface()
	if input_mapping_context:
		GUIDE.enable_mapping_context(input_mapping_context)
	if background_music:
		GameManager.play_music(background_music)

func configure_interface():
	var interface:Control = load(interface_scene).instantiate()
	GameManager.game_interface = interface
	GameManager.add_child(interface)
