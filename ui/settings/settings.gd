extends Control

@onready var text_speed_slider: HSlider = %TextSpeedSlider
@onready var text_speed_label: Label = %TextSpeedLabel

func _ready() -> void:
	setup_signals()

func setup_signals() -> void:
	text_speed_slider.value_changed.connect(_on_text_speed_slider_changed)

#region Callbacks

func _on_text_speed_slider_changed(value: int) -> void:
	const MAX: int = 4
	
	var text_speed_modifier: int = 0 if value >= MAX else 2 ** value
	GameSettings.set_text_speed_modifier(text_speed_modifier)

#endregion
