extends AudioStreamPlayer
@export var active_index:int = 1
@export var stream_count:int = 5

func _ready() -> void:
	var _stream:AudioStreamSynchronized = stream as AudioStreamSynchronized
	for idx:int in range(stream_count):
		_stream.set_sync_stream_volume(idx,linear_to_db(0))
	stream.set_sync_stream_volume(active_index,linear_to_db(1))
	play()

func on_crossfade_music(index:int)->void:
	print(index)
	for idx:int in range(stream_count):
		if idx == index:
			stream.set_sync_stream_volume(index,linear_to_db(1))
		else:
			stream.set_sync_stream_volume(idx,linear_to_db(0))
