extends Control

func _ready():
	visible=false
	var music_credits:String = GameManager.get_current_music_attribution()
	set_music_attribution(music_credits)
	GameManager.music_now_playing.connect(set_music_attribution)

func _process(_delta):
	visible = get_tree().paused

func set_music_attribution(text:String):
	%NowPlayingLabel.visible = text != ""
	%MusicNowPlayingLabel.text = text

func _on_quit_button_confirmed_press() -> void:
	get_tree().quit()

func _on_main_menu_button_confirmed_press() -> void:
	GameManager.change_scene(Constants.MAIN_MENU)


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible=false
