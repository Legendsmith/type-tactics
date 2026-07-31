@tool
extends Control

## The time in seconds between when a 
const SAVE_DEBOUNCE_TIME: float = 1.0

#region Setting Control Nodes
@onready var text_speed_slider: HSlider = %TextSpeedSlider
@onready var text_speed_label: Label = %TextSpeedLabel

@onready var battle_animation_slider: HSlider = %BattleAnimationSlider
@onready var battle_animation_speed_label: Label = %BattleAnimationSpeedLabel

@onready var auto_run_disabled_button: Button = %AutoRunDisabledButton
@onready var auto_run_enabled_button: Button = %AutoRunEnabledButton

@onready var vibration_strength_slider: HSlider = %VibrationStrengthSlider


@onready var window_mode_options: OptionButton = %WindowModeOptions
#@onready var window_resolution_options: OptionButton = %WindowResolutionOptions
@onready var vsync_mode_options: OptionButton = %VSyncModeOptions
@onready var target_fps_options: OptionButton = %TargetFpsOptions


@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var character_voice_volume_slider: HSlider = %CharacterVoiceVolumeSlider
#endregion

var _text_speed_values: Array[float] = []
var _text_speed_labels: Array[StringName] = []

var _save_debounce_timer: Timer = Timer.new()


func _ready() -> void:
	add_child(_save_debounce_timer, false)
	
	_save_debounce_timer.one_shot = true
	_save_debounce_timer.name = &"SaveDebounceTimer"
	_save_debounce_timer.wait_time = SAVE_DEBOUNCE_TIME
	_save_debounce_timer.timeout.connect(GameSettings.save_settings)
	
	_setup_controls()
	_initialize_values()
	_setup_signals()


## Builds and modifies control nodes at runtime before first showing the settings scene.
func _setup_controls() -> void:
	text_speed_slider.step = 1.0
	text_speed_slider.min_value = 0.0
	text_speed_slider.max_value = _text_speed_values.size() - 1
	text_speed_slider.tick_count = _text_speed_values.size()


## Populates the control nodes with the current vaues stored in the game settings.
func _initialize_values() -> void:
	var text_speed_option: int = _text_speed_values.find_custom(is_equal_approx.bind(GameSettings.text_speed_modifier))
	if text_speed_option == -1:
		push_warning("text speed option not found, displaying first option")
		text_speed_option = 0
	
	text_speed_slider.set_value_no_signal(text_speed_option)
	text_speed_label.text = tr(_text_speed_labels[text_speed_option])
	
	#TODO: initialize battle animation speed
	
	auto_run_disabled_button.set_pressed_no_signal(not GameSettings.auto_run_enabled)
	auto_run_enabled_button.set_pressed_no_signal(GameSettings.auto_run_enabled)
	
	vibration_strength_slider.set_value_no_signal(GameSettings.vibration_strength)
	
	
	window_mode_options.select(window_mode_options.get_item_index(GameSettings.window_mode))
	vsync_mode_options.select(vsync_mode_options.get_item_index(GameSettings.vsync_mode))
	target_fps_options.select(target_fps_options.get_item_index(GameSettings.target_fps))
	
	
	master_volume_slider.set_value_no_signal(GameSettings.master_volume)
	music_volume_slider.set_value_no_signal(GameSettings.music_volume)
	sfx_volume_slider.set_value_no_signal(GameSettings.sfx_volume)
	character_voice_volume_slider.set_value_no_signal(GameSettings.character_voice_volume)
	
	if GameSettings.vsync_mode == DisplayServer.VSyncMode.VSYNC_DISABLED:
		target_fps_options.disabled = false
	else:
		target_fps_options.disabled = true


## Connects the signals from the control nodes in order to react to the changes in the settings
func _setup_signals() -> void:
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	# battle_animation_slider.value_changed.connect(_on_battle_animation_changed)
	auto_run_disabled_button.pressed.connect(_on_auto_run_disabled_pressed)
	auto_run_enabled_button.pressed.connect(_on_auto_run_enabled_pressed)
	vibration_strength_slider.value_changed.connect(_on_vibration_strength_changed)
	
	window_mode_options.item_selected.connect(_on_window_mode_selected)
	vsync_mode_options.item_selected.connect(_on_vsync_mode_selected)
	target_fps_options.item_selected.connect(_on_target_fps_selected)
	
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	character_voice_volume_slider.value_changed.connect(_on_character_voice_volume_changed)


func queue_save() -> void:
	_save_debounce_timer.start()


#region Callbacks

func _on_text_speed_changed(value: int) -> void:
	text_speed_label.text = tr(_text_speed_labels[value])
	GameSettings.text_speed_modifier = _text_speed_values[value]
	queue_save()


# func _on_battle_animation_changed(value: int) -> void:
# 	queue_save()


func _on_auto_run_disabled_pressed() -> void:
	GameSettings.auto_run_enabled = false
	queue_save()


func _on_auto_run_enabled_pressed() -> void:
	GameSettings.auto_run_enabled = true
	queue_save()


func _on_vibration_strength_changed(value: float) -> void:
	GameSettings.vibration_strength = value
	queue_save()


func _on_window_mode_selected(index: int) -> void:
	GameSettings.window_mode = window_mode_options.get_item_id(index) as DisplayServer.WindowMode
	queue_save()


func _on_vsync_mode_selected(index: int) -> void:
	GameSettings.vsync_mode = vsync_mode_options.get_item_id(index) as DisplayServer.VSyncMode
	
	if GameSettings.vsync_mode == DisplayServer.VSyncMode.VSYNC_DISABLED:
		target_fps_options.disabled = false
	else:
		target_fps_options.disabled = true
	
	queue_save()


func _on_target_fps_selected(index: int) -> void:
	var fps_text: String = target_fps_options.get_item_text(index)
	GameSettings.target_fps = int(fps_text)
	queue_save()


func _on_master_volume_changed(value: float) -> void:
	GameSettings.master_volume = value
	queue_save()


func _on_music_volume_changed(value: float) -> void:
	GameSettings.music_volume = value
	queue_save()


func _on_sfx_volume_changed(value: float) -> void:
	GameSettings.sfx_volume = value
	queue_save()


func _on_character_voice_volume_changed(value) -> void:
	GameSettings.character_voice_volume = value
	queue_save()
#endregion


#region Custom Property List
func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	
	props.append({
		"name": "text_speed_options/count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
	})
	
	for i in _text_speed_values.size():
		props.append({
			"name": "text_speed_options/%d/value" % i,
			"type": TYPE_FLOAT,
		})
	
		props.append({
			"name": "text_speed_options/%d/translation_key" % i,
			"type": TYPE_STRING_NAME,
		})
	
	return props

func _get(property: StringName) -> Variant:
	var parts: PackedStringArray = property.split('/')
	
	if parts[0] == "text_speed_options":
		if parts[1] == "count":
			return _text_speed_values.size()
		
		else:
			var index: int = int(parts[1])
	
			if parts[2] == "value":
				return _text_speed_values[index]
			elif parts[2] == "translation_key":
				return _text_speed_labels[index]
	
	return null


func _set(property: StringName, value: Variant) -> bool:
	var parts: PackedStringArray = property.split('/')
	
	if parts[0] == "text_speed_options":
		if parts[1] == "count":
			_text_speed_values.resize(value)
			_text_speed_labels.resize(value)
			notify_property_list_changed()
			return true
		
		else:
			var index: int = int(parts[1])
	
			if parts[2] == "value":
				_text_speed_values[index] = value
			elif parts[2] == "translation_key":
				_text_speed_labels[index] = value
	
	return false


# func _property_can_revert(property: StringName) -> bool:
# 	return false

#endregion
