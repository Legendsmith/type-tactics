extends TextureRect
@export var decay_rate:float = 0.02
var value:float = 0.1


func _process(delta: float) -> void:
	material.set_shader_parameter(&"time_add",Vector2(value,0))
	value = move_toward(value,0,delta * decay_rate)

func on_audio_analyser(new_value:float):
	value = max(value,new_value)
