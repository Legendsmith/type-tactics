extends AudioStreamPlayer
@export var active_index:int = 1
@export var stream_count:int = 5
@export var fade_time:float = 0.25
var tween:Tween

func _ready() -> void:
	var _stream:AudioStreamSynchronized = stream as AudioStreamSynchronized
	for idx:int in range(stream_count):
		_stream.set_sync_stream_volume(idx,linear_to_db(0))
	stream.set_sync_stream_volume(active_index,linear_to_db(1))
	play()

func on_crossfade_music(index:int)->void:
	print(index)
	if tween:
		tween.stop()
	tween = create_tween().set_parallel(true)
	for idx:int in range(stream_count):
		if idx == index:
			tween.tween_method(set_substream_volume.bind(index),db_to_linear(stream.get_sync_stream_volume(index)),1,fade_time)
		else:
			tween.tween_method(set_substream_volume.bind(idx),db_to_linear(stream.get_sync_stream_volume(idx)),0,fade_time)

func set_substream_volume(linear:float,index:int):
	stream.set_sync_stream_volume(index,linear_to_db(linear))
