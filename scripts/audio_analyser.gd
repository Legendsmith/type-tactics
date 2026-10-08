extends Node
signal bass(magnitude:float)
signal treble(magnitude:float)


@export var smoothing_factor:float = 4
#@export var bass_threshold: float = 0.03
#@export var treble_threshold:float = 0.02
@export_category("Frequency Analysis")
@export_range(40,125,1.0,"suffix:hz","exp") var bass_min:float = 40
@export_range(70,20000,1.0,"suffix:hz","exp") var bass_max:float = 200
@export_range(125,20000,1.0,"suffix:hz","exp") var treble_min:float = 280
@export_range(125,20000,1.0,"suffix:hz","exp") var treble_max:float = 2000


var spectrum: AudioEffectSpectrumAnalyzerInstance
var previous_bass: float = 0.0
var previous_treble: float = 0

func _ready() -> void:
	await get_tree().current_scene.ready
	spectrum = GameManager.get_or_add_spectrum_analyzer()


func _process(delta):
	if GameManager.current_player.playing:
		var magnitude_bass:float = analyse_beat(bass_min,bass_max,AudioEffectSpectrumAnalyzerInstance.MagnitudeMode.MAGNITUDE_AVERAGE)
		var magnitude_treble:float = analyse_beat(treble_min,treble_max,AudioEffectSpectrumAnalyzerInstance.MagnitudeMode.MAGNITUDE_MAX)
		bass.emit(magnitude_bass-previous_bass)
		treble.emit(magnitude_treble-previous_treble)
		previous_bass = lerpf(previous_bass,magnitude_bass,smoothing_factor*delta)
		previous_treble = lerpf(previous_treble,magnitude_treble,smoothing_factor*delta)

func analyse_beat(freq_min:float,freq_max:float,type:AudioEffectSpectrumAnalyzerInstance.MagnitudeMode):
	var mag_max:Vector2 = spectrum.get_magnitude_for_frequency_range(freq_min, freq_max,type)
	return max(mag_max.x,mag_max.y)
