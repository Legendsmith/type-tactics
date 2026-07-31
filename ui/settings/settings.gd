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

#FIXME: this doesn't appear correctly in the editor due to not being registered in the global class list
@export var _text_speed_options: Array[SpeedOption] = [
	SpeedOption.new(1.0, &"ts_slow"),
	SpeedOption.new(3.0, &"ts_normal"),
	SpeedOption.new(6.0, &"ts_fast"),
	SpeedOption.new(9.0, &"ts_faster"),
	SpeedOption.new(0.0, &"ts_instant"),
]

@export var _battle_animation_speed_options: Array[SpeedOption] = [
	SpeedOption.new(1.0, &"ts_normal"),
	SpeedOption.new(3.0, &"ts_fast"),
	SpeedOption.new(4.0, &"ts_faster"),
	SpeedOption.new(0.0, &"ts_instant"),
]

@export var _window_mode_map: Array[DisplayServer.WindowMode] = [
	DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
	DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
]

@export var _vsync_mode_map: Array[DisplayServer.VSyncMode] = [
	DisplayServer.VSyncMode.VSYNC_DISABLED,
	DisplayServer.VSyncMode.VSYNC_ADAPTIVE,
	DisplayServer.VSyncMode.VSYNC_MAILBOX,
]


var _save_debounce_timer: Timer


func _init() -> void:
	_save_debounce_timer = Timer.new()
	_save_debounce_timer.name = &"SaveDebounceTimer"
	_save_debounce_timer.wait_time = SAVE_DEBOUNCE_TIME
	_save_debounce_timer.timeout.connect(GameSettings.save_settings)
	add_child(_save_debounce_timer, false, INTERNAL_MODE_BACK)


func _ready() -> void:
	_setup_controls()
	_initialize_values()
	_setup_signals()


## Builds and modifies control nodes at runtime before first showing the settings scene.
func _setup_controls() -> void:
	text_speed_slider.max_value = _text_speed_options.size()
	text_speed_slider.tick_count = _text_speed_options.size()

#TODO: populate all controls with the vaues from teh game settings
## Populates the control nodes with the current vaues stored in the game settings.
func _initialize_values() -> void:
	if GameSettings.text_speed_modifier == 0:
		var fastest_option: SpeedOption = _text_speed_options.back()

		text_speed_slider.set_value_no_signal(fastest_option.value)
		text_speed_label.text = tr(fastest_option.translation_key)
	else:
		var selected_index: int = _text_speed_options.find_custom(func (v: int) -> bool:
			return v == GameSettings.text_speed_modifier
		)
		var option: SpeedOption = _text_speed_options[selected_index] if selected_index != -1 else _text_speed_options.front()

		text_speed_slider.set_value_no_signal(option.value)
		text_speed_label.text = tr(option.translation_key)


## Connects the signals from the control nodes in order to react to the changes in the settings
func _setup_signals() -> void:
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	battle_animation_slider.value_changed.connect(_on_battle_animation_changed)
	auto_run_disabled_button.pressed.connect(_on_auto_run_disabled_pressed)
	auto_run_enabled_button.pressed.connect(_on_auto_run_enabled_pressed)
	vibration_strength_slider.changed.connect(_on_vibration_strength_changed)

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
	var selected_option: SpeedOption = _text_speed_options[value]

	text_speed_label.text = tr(selected_option.translation_key)
	GameSettings.set_text_speed_modifier(selected_option.value)
	queue_save()


func _on_battle_animation_changed(value: int) -> void:
	var selected_option: SpeedOption = _battle_animation_speed_options[value]

	battle_animation_speed_label.text = tr(selected_option.translation_key)
	GameSettings.set_battle_animation_speed(selected_option.value)
	queue_save()


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
	var mode_id: int = window_mode_options.get_item_id(index)
	GameSettings.window_mode = _window_mode_map[mode_id]
	queue_save()


func _on_vsync_mode_selected(index: int) -> void:
	var mode_id: int = vsync_mode_options.get_item_id(index)
	GameSettings.vsync_mode = _vsync_mode_map[mode_id]
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


#FIXME: this doesn't work, instead use a 
class SpeedOption extends Resource:
	@export_range(0.0, 999.0, 0.1, "or_greater", "hide_control") var value: float
	@export var translation_key: StringName

	func _init(v: float, tk: StringName) -> void:
		value = v
		translation_key = tk
