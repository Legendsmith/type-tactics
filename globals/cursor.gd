extends Node
var anim_timer: Timer
var anim_frames:Array[Image]
var anim_idx: int = 0

enum Type {DEFAULT,AIM,INTERACT,CANT_INTERACT,TALK,TALK_REPEAT}

var cursors:ImagePack
	

func _ready() -> void:
	cursors = load("uid://c3ltxuww0js4j")
	anim_timer = Timer.new()
	anim_timer.autostart = false
	anim_timer.wait_time = 0.2
	add_child(anim_timer)
	anim_timer.timeout.connect(animate_cursor)
	set_cursor(Type.DEFAULT)

func set_cursor(type:int) -> void:
	Input.set_custom_mouse_cursor(cursors.images[type], Input.CURSOR_ARROW, Vector2(4,4))
	if type in cursors.alt_images:
		anim_frames=[cursors.images[type],cursors.alt_images[type]]
		anim_timer.start()
	else:
		anim_idx=0
		anim_timer.stop()

func animate_cursor() -> void:
	anim_idx = wrapi(anim_idx,0,anim_frames.size())
	Input.set_custom_mouse_cursor(anim_frames[anim_idx], Input.CURSOR_ARROW, Vector2(4,4))
	anim_idx+=1
