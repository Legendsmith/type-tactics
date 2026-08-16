extends CanvasItem
@export var base_modulate:Color = Color.DIM_GRAY
@export var beat_modulate:Color = Color.WHITE
@export var modulate_rate:float = 2
@export var decay_rate:float = 0.1
var last_value:float = 0
var value:float = 0

func _ready() -> void:
	self_modulate = base_modulate

func _process(delta: float) -> void:
	last_value = move_toward(last_value,value,delta * modulate_rate)
	self_modulate = lerp(base_modulate,beat_modulate,clampf(last_value,0,1))
	value = move_toward(value,0,delta * decay_rate)
	

func on_audio_analyser(new_value:float):
	value = max(value,new_value)
