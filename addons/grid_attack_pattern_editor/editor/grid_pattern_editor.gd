@tool
extends VBoxContainer

@onready var grid_canvas := %GridCanvas
@onready var zoom_text: Label = %ZoomText

var pattern: AttackPatternResource

func set_pattern(pattern: AttackPatternResource) -> void:
	grid_canvas.set_pattern(pattern)


func _on_grid_canvas_zoom_changed() -> void:
	zoom_text.text = "%1.3f" % grid_canvas.zoom
