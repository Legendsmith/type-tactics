extends Control

@export_custom(0,"scene") var new_game_scene:String = "uid://dn7yyypoxhesl"
@export var background_music:AudioStream

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_button: Button = %ExitButton

@onready var button_pressed_stream_player: AudioStreamPlayer = %ButtonPressedStreamPlayer
@onready var button_highlighted_stream_player: AudioStreamPlayer = %ButtonHighlightedStreamPlayer

var _play_highlight_queued: bool = false

func _ready() -> void:
	setup_signals()
	GameManager.play_music(background_music)

func setup_signals() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	continue_button.pressed.connect(_on_button_pressed)
	new_game_button.pressed.connect(_on_button_pressed)
	settings_button.pressed.connect(_on_button_pressed)
	credits_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)
	
	continue_button.focus_entered.connect(_on_button_highlighted, CONNECT_DEFERRED)
	new_game_button.focus_entered.connect(_on_button_highlighted, CONNECT_DEFERRED)
	settings_button.focus_entered.connect(_on_button_highlighted, CONNECT_DEFERRED)
	credits_button.focus_entered.connect(_on_button_highlighted, CONNECT_DEFERRED)
	exit_button.focus_entered.connect(_on_button_highlighted, CONNECT_DEFERRED)

#region Callbacks

func _on_continue_pressed() -> void:
	pass

func _on_new_game_pressed() -> void:
	GameManager.change_scene(new_game_scene,"instant")

func _on_settings_pressed() -> void:
	pass

func _on_credits_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	button_pressed_stream_player.play()

func _on_button_highlighted() -> void:
	_queue_play_highlight()

#endregion

func _queue_play_highlight() -> void:
	if _play_highlight_queued:
		return
	
	_play_highlight_queued = true
	_play_highlight.call_deferred()

func _play_highlight():
	_play_highlight_queued = false
	button_highlighted_stream_player.play()
