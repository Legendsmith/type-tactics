extends Control

#region Setting Control Nodes
@onready var text_speed_slider: HSlider = %TextSpeedSlider
@onready var text_speed_label: Label = %TextSpeedLabel

@onready var battle_animation_slider: HSlider = %BattleAnimationSlider
@onready var battle_animation_speed_label: Label = %BattleAnimationSpeedLabel

@onready var auto_run_disabled_button: Button = %AutoRunDisabledButton
@onready var auto_run_enabled_button: Button = %AutoRunEnabledButton

@onready var vibration_strength_slider: HSlider = %VibrationStrengthSlider


@onready var window_mode_options: OptionButton = %WindowModeOptions
@onready var window_resolution_options: OptionButton = %WindowResolutionOptions
@onready var v_sync_mode_options: OptionButton = %VSyncModeOptions
@onready var target_fps_options: OptionButton = %TargetFpsOptions


@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var character_voice_volume_slider: HSlider = %CharacterVoiceVolumeSlider

#endregion

func _ready() -> void:
	initialize_values()
	setup_signals()

func initialize_values() -> void:
	pass

func setup_signals() -> void:
	text_speed_slider.value_changed.connect(_on_text_speed_slider_changed)

#region Callbacks

func _on_text_speed_slider_changed(value: int) -> void:
	const MAX: int = 4
	
	var text_speed_modifier: int = 0 if value >= MAX else 2 ** value
	GameSettings.set_text_speed_modifier(text_speed_modifier)

#endregion
