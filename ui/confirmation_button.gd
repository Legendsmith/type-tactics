extends Button
signal confirmed_press

@export var confirm_text:String = "Really?"
@export_range(0.22,5.0,0.02) var confirm_timeout:float = 1.22

var regular_text:String
var confirm:bool = false
var timer:Timer = Timer.new()

func _ready():
	regular_text = text
	timer.wait_time=confirm_timeout
	timer.ignore_time_scale = true
	timer.timeout.connect(
		func():
			confirm=false
			text=regular_text
	)
	add_child(timer)

func _on_pressed():
	if confirm:
		confirmed_press.emit()
	else:
		text = confirm_text
		confirm = true
		timer.start()
