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

func change_scene(scene_path: String,transition:StringName=&"fade", clear_interface:bool = true,extra_data:Dictionary[StringName,Variant]={}):
	if not scene_changing:
		%Blackout.visible=true
		scene_changing = true
		anim.play(transition)
		await anim.animation_finished
		if clear_interface and is_instance_valid(game_interface):
			game_interface.queue_free()
		if extra_data:
			var new_scene:Node = load(scene_path).instantiate()
			for key:StringName in extra_data:
				new_scene.set(key,extra_data[key])
			var error:int = get_tree().change_scene_to_node(new_scene)
			if error:
				push_warning("Provided scene path is invalid or could not be loaded")
				%Blackout.visible=false
				return
		else:
			get_tree().change_scene_to_file(scene_path)
		anim.play(transition,1,-1,true) # play the transition backwards
		scene_changing = false
		%Blackout.visible=false

			
