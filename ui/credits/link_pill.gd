extends PanelContainer

@export var link: String

func _gui_input(event: InputEvent) -> void:
	if link.is_empty():
		return
	
	var mb: InputEventMouseButton = event as InputEventMouseButton
	
	if mb and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		OS.shell_open(link)
