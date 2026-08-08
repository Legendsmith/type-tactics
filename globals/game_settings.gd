extends Node

const CONFIG_PATH: String = "user://settings.cfg"

const SECTION_GAMEPLAY: String = "Gameplay"
const SECTION_GRAPHICS: String = "Graphics"
const SECTION_AUDIO: String = "Audio"
const SECTION_CONTROLS: String = "Controls"

var config: ConfigFile = ConfigFile.new()

# Gameplay
## Modifies how quickly text gets revealed in dialog. When set to 0, text gets instantly revealed.
var text_speed_modifier: float = 1: set = set_text_speed_modifier
## Indicates how fast batle animations are playing.
var battle_animation_speed: float = 1.0: set = set_battle_animation_speed
## Indicates if the player character is automatically running by default.
var auto_run_enabled: bool = false
## Determines scale at which vibrations are sent to the player's input device.
var vibration_strength: float = 0.5: set = set_vibration_strength
## Indicates if the overworld interactions with other npcs should be controlled via mouse or keyboard direction.
var mouse_interaction_enabled:bool = true


# Graphics
## Determines if the game is played in a window or set to full screen
var window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN: set = set_window_mode
## Determines what strategy of VSync is used. If VSync is used, target_fps is ignored.
var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ADAPTIVE: set = set_vsync_mode
## Determines how often the engine attempt to draw frames per second. When set to 0, no artificial cap is set. 
## When making use of any VSync strategy, this property has no effect.
var target_fps: int = 60: set = set_target_fps

# Audio
var master_volume: float = 0.5: set = set_master_volume
var music_volume: float = 1.0: set = set_music_volume
var sfx_volume: float = 1.0: set = set_sfx_volume
var character_voice_volume: float = 1.0: set = set_character_voice_volume


func _ready() -> void:
	# When a config file does not exist, force a write to disk by saving the current settings.
	if load_settings() != OK:
		save_settings()


## Loads the settings from the configuration file if available, otherwise uses default options.
func load_settings() -> Error:
	var load_result := config.load(CONFIG_PATH)

	text_speed_modifier = config.get_value(SECTION_GAMEPLAY, "text_speed_modifier", text_speed_modifier)
	battle_animation_speed = config.get_value(SECTION_GAMEPLAY, "battle_animation_speed", battle_animation_speed)
	auto_run_enabled = config.get_value(SECTION_GAMEPLAY, "auto_run_enabled", auto_run_enabled)
	vibration_strength = config.get_value(SECTION_GAMEPLAY, "vibration_strength", vibration_strength)

	window_mode = config.get_value(SECTION_GRAPHICS, "window_mode", window_mode)
	vsync_mode = config.get_value(SECTION_GRAPHICS, "vsync_mode", vsync_mode)
	target_fps = config.get_value(SECTION_GRAPHICS, "target_fps", target_fps)

	master_volume = config.get_value(SECTION_AUDIO, "master_volume", master_volume)
	music_volume = config.get_value(SECTION_AUDIO, "music_volume", music_volume)
	sfx_volume = config.get_value(SECTION_AUDIO, "sfx_volume", sfx_volume)
	character_voice_volume = config.get_value(SECTION_AUDIO, "character_voice_volume", character_voice_volume)

	return load_result


## Saves the current used settings to disk.
func save_settings() -> Error:
	config.set_value(SECTION_GAMEPLAY, "text_speed_modifier", text_speed_modifier)
	config.set_value(SECTION_GAMEPLAY, "battle_animation_speed", battle_animation_speed)
	config.set_value(SECTION_GAMEPLAY, "auto_run_enabled", auto_run_enabled)
	config.set_value(SECTION_GAMEPLAY, "vibration_strength", vibration_strength)
	
	config.set_value(SECTION_GRAPHICS, "window_mode", window_mode)
	config.set_value(SECTION_GRAPHICS, "vsync_mode", vsync_mode)
	config.set_value(SECTION_GRAPHICS, "target_fps", target_fps)
	
	config.set_value(SECTION_AUDIO, "master_volume", master_volume)
	config.set_value(SECTION_AUDIO, "music_volume", music_volume)
	config.set_value(SECTION_AUDIO, "sfx_volume", sfx_volume)
	config.set_value(SECTION_AUDIO, "character_voice_volume", character_voice_volume)
	
	var result: Error = config.save(CONFIG_PATH)
	if result == OK:
		print("Succesfully saved settings to: '%s'" % ProjectSettings.globalize_path(CONFIG_PATH))
	else:
		push_error("Failed to save user settings to '%s'. Error code (%d): '%s'" % [ProjectSettings.globalize_path(CONFIG_PATH), result, error_string(result)])
	
	return result


## Sets the speed at which text gets revealed in dialog. 
## When set to 0, text is displayed instantly
func set_text_speed_modifier(modifier: float) -> void:
	const BASE_REVEAL_TIME: float = 0.1
	text_speed_modifier = maxf(0.0, modifier)
	
	Dialogic.Settings.text_speed = 0.0 if modifier == 0.0 else BASE_REVEAL_TIME / modifier

# TODO: Current implementation is a prediction for how it's used. 
# 		When it's actually used, please revisit this.
## Sets the speed at which battle animations play.
func set_battle_animation_speed(speed: float) -> void:
	battle_animation_speed = maxf(0.1, speed)


## Sets the intensity modifier at which input device vibration feedback is given. Ranges from 0 to 1.
func set_vibration_strength(strength: float) -> void:
	vibration_strength = clampf(strength, 0.0, 1.0)

## Sets how the window is placed on screen.
func set_window_mode(mode: DisplayServer.WindowMode) -> void:
	window_mode = mode
	var is_fullscreen = mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN 
	
	DisplayServer.window_set_mode(window_mode)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, not is_fullscreen)


## Sets the VSync mode used by the game.
func set_vsync_mode(mode: DisplayServer.VSyncMode) -> void:
	vsync_mode = mode

	DisplayServer.window_set_vsync_mode(vsync_mode)


## Sets the target frames per second the game attempts to target. When set to 0, frames are uncapped.
## Only has an effect when VSync is not used.
func set_target_fps(target: int) -> void:
	target_fps = maxi(target, 0)
	
	Engine.max_fps = target_fps


## Sets the volume of all buses mixed together.
func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	
	AudioServer.set_bus_volume_linear(Constants.MASTER_BUS_INDEX, master_volume)


## Sets the volume of music bus.
func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	
	AudioServer.set_bus_volume_linear(Constants.MUSIC_BUS_INDEX, music_volume)


## Sets the volume of the sound effects bus.
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	
	AudioServer.set_bus_volume_linear(Constants.SFX_BUS_INDEX, sfx_volume)


## Sets the volume of character voices.
func set_character_voice_volume(volume: float) -> void:
	character_voice_volume = clampf(volume, 0.0, 1.0)
	
	AudioServer.set_bus_volume_linear(Constants.CHARACTER_VOICING_INDEX, character_voice_volume)
