@tool
extends EditorPlugin

var dock: EditorDock
var grid_editor: Control

func _enter_tree() -> void:
	dock = EditorDock.new()
	dock.title = "Patern Editor"
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	
	#grid_editor = preload("uid://b2tqdxd22yotc").new()
	dock.add_child(grid_editor)
	
	add_dock(dock)
	dock.close()

func _exit_tree() -> void:
	dock.queue_free()
	grid_editor.queue_free()

func _handles(object: Object) -> bool:
	return object is AttackPatternResource

func _edit(object: Object) -> void:
	if object == null:
		dock.close()
	else:
		dock.open()
	
	grid_editor.set_pattern(object)
