@tool
extends EditorPlugin

var plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	plugin = preload("res://addons/scene_reference/scene_reference_inspector_pugin.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
