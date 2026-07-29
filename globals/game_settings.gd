extends Node

var ui_animation_speed:float = 1.0


func set_text_speed_modifier(modifier: int) -> void:
	const BASE_SPEED: float = 0.1
	
	# TODO: store the modifier separately so it can be loaded and applied
	Dialogic.Settings.text_speed = BASE_SPEED * modifier
