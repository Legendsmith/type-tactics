extends CanvasLayer
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)

@onready var fade_rect:ColorRect = $Blackout
@onready var anim:AnimationPlayer = $AnimationPlayer
var scene_changing:bool = false
var game_interface:Control

## Music Variables
const DEFAULT_FADE_TIME:float = 1.5

@onready var player1: AudioStreamPlayer = %MusicPlayer1
@onready var player2: AudioStreamPlayer = %MusicPlayer2

var current_player: AudioStreamPlayer = player1
var next_player: AudioStreamPlayer = player2
var fade_out_tween

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

			
#region Music

func play_music(new_audio_stream:AudioStream):
	if current_player.playing:
		crossfade_to(new_audio_stream)
	else:
		current_player.audio_stream = new_audio_stream
		current_player.play()
		fade_in(current_player)
	if new_audio_stream is AudioStreamRandomizer: # Make it loop if it's a music randomizer resource.
		current_player.finished.connect(current_player.play)
	elif current_player.finished.is_connected(current_player.play):
		current_player.finished.disconnect(current_player.play)
		
 
func fade_in(player: AudioStreamPlayer,fade_time:float=DEFAULT_FADE_TIME,final_volume:float=1) -> Tween:
	player.volume_linear = 0
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", final_volume, fade_time)
	return tween

func fade_out(player: AudioStreamPlayer,fade_time:float=DEFAULT_FADE_TIME) -> Tween:
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", 0, fade_time)
	tween.tween_callback(player.stop)
	return tween


func crossfade_to(new_track: AudioStream,fade_time:float=DEFAULT_FADE_TIME):
	next_player.stream = new_track
	next_player.volume_db = -60
	next_player.play()

	var tween = create_tween().set_parallel(true)
	tween.tween_property(current_player, "volume_linear", 0, fade_time)
	tween.tween_property(next_player, "volume_linear", 1, fade_time)

	tween.finished.connect(func():
		current_player.stop()
		var temp = current_player
		current_player = next_player
		next_player = temp
	)

func fade_out_and_pause(player: AudioStreamPlayer)->Tween:
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(player, "volume_linear", 0, DEFAULT_FADE_TIME)
	fade_out_tween.tween_callback(func():
		player.stream_paused = true
	)
	return fade_out_tween

func stop_all_music():
	for player in [player1, player2]:
		if player.playing:
			fade_out(player)



#endregion
