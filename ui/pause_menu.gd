extends Control

func _ready():
	visible=false

func _process(_delta):
	visible = get_tree().paused

func _on_quit_button_confirmed_press() -> void:
	get_tree().quit()

func _on_main_menu_button_confirmed_press() -> void:
	GameManager.change_scene(Constants.MAIN_MENU)


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible=false
