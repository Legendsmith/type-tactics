extends Camera2D
@export var max_zoom: float = 4
@export var min_zoom: float = 0.5
@export var zoom_step: float = 0.1
@export var move_speed: float = 500
@onready var _zoom_step: Vector2 = Vector2.ONE * zoom_step
@onready var _max_zoom: Vector2 = Vector2.ONE * max_zoom
@onready var _min_zoom: Vector2 = Vector2.ONE * min_zoom

var _dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	_dragging = Input.is_action_pressed(&"camera_drag")
	if event is InputEventMouseMotion and _dragging:
		#var motion:InputEventMouseMotion = event as InputEventMouseMotion
		offset-=event.relative/get_zoom()
	### Zoom
	var new_zoom: Vector2 = get_zoom()
	if event.is_action_pressed("camera_zoom_in"):
		new_zoom += _zoom_step
	elif event.is_action_pressed("camera_zoom_out"):
		new_zoom -= _zoom_step
	set_zoom(new_zoom.clamp(_min_zoom, _max_zoom))
	

#func _process(delta: float) -> void:
#	var input_dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up",&"move_down")
#	if input_dir:
#		global_position += input_dir * move_speed * delta
