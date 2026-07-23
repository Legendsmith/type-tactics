extends CanvasLayer
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)

@onready var fade_rect:ColorRect = $Blackout
@onready var anim:AnimationPlayer = $AnimationPlayer
var scene_changing:bool = false
var game_interface:Control

func _ready():
	anim.play("fade",1,-1,true)

func change_scene(scene_path: String,transition:StringName=&"fade", clear_interface:bool = true):
	if not scene_changing:
		scene_changing = true
		anim.play(transition)
		await anim.animation_finished
		get_tree().change_scene_to_file(scene_path)
		anim.play(transition,1,-1,true) # play the transition backwards
		scene_changing = false
	if clear_interface and is_instance_valid(game_interface):
		game_interface.queue_free()
