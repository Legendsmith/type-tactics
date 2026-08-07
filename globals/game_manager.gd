extends CanvasLayer
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
signal music_now_playing(attribution:String)

@onready var fade_rect:ColorRect = $Blackout
@onready var anim:AnimationPlayer = $AnimationPlayer
var scene_changing:bool = false
var game_interface:Control

## Music Variables
const ARTIST_SEPARATOR:String = ", "
const DEFAULT_FADE_TIME:float = 1.5
var music_attribution:Dictionary[String,PackedStringArray]

@onready var player1: AudioStreamPlayer = %MusicPlayer1
@onready var player2: AudioStreamPlayer = %MusicPlayer2

@onready var current_player: AudioStreamPlayer = player1
@onready var next_player: AudioStreamPlayer = player2

var _playlist:Array[AudioStream]
var _playlist_idx:int = -1

var fade_out_tween

func _ready():
	anim.play("fade",1,-1,true)
	current_player.finished.connect(play_next_in_queue)
	next_player.finished.connect(play_next_in_queue)

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

func build_attribution_string(stream:AudioStream) -> String:
	var tags:Dictionary = stream.tags
	if tags:
		return "%s — %s" % [tags["title"],ARTIST_SEPARATOR.join([tags.get("composer",""),tags.get("artist","")]).trim_prefix(ARTIST_SEPARATOR).trim_suffix(ARTIST_SEPARATOR)]
	else:
		return ""


func play_next_in_queue() -> void:
	if _playlist.size():
		var next_idx:int = wrapi(_playlist_idx+1, 0, _playlist.size())
		var next_song:AudioStream = _playlist[next_idx]
		current_player.stream = next_song
		current_player.play()
		music_now_playing.emit(build_attribution_string(next_song))


func get_current_music_attribution()-> String:
	var stream:AudioStream
	var player:AudioStreamPlayer
	if current_player.playing:
		player = current_player
	elif next_player.playing:
		player = next_player
	else: #if nothing's playing, return empty array
		return ""
	stream = player.stream
	if stream is AudioStreamOggVorbis or stream is AudioStreamWAV:
		return build_attribution_string(stream)
	else:
		return ""


func set_playlist(playlist:AudioStreamPlaylist):
	_playlist.clear()
	_playlist.resize(playlist.stream_count)
	for i:int in range(playlist.stream_count):
		_playlist[i] = playlist.get_list_stream(i)
	

func play_music(new_audio_stream:AudioStream,crossfade:bool=true, clear_playlist:bool=true):
	var stream:AudioStream = new_audio_stream
	if new_audio_stream is AudioStreamPlaylist:
		set_playlist(new_audio_stream)
		_playlist_idx = randi() % _playlist.size() if new_audio_stream.shuffle else 0
		stream = _playlist[_playlist_idx]
	elif _playlist.size() and new_audio_stream in _playlist:
		_playlist_idx = _playlist.find(new_audio_stream)
	elif clear_playlist:
		_playlist.clear()
		_playlist_idx=-1
	if current_player.playing and crossfade:
		crossfade_to(stream)
	else:
		current_player.stream = stream
		current_player.play()
		fade_in(current_player)
	music_now_playing.emit(build_attribution_string(stream))

 
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
	next_player.volume_linear = 0
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
	music_now_playing.emit("")



#endregion
