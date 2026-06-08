extends EditorInspectorPlugin


var scene_reference_editor := preload("res://addons/scene_reference/scene_reference_property_editor.gd")


func _can_handle(object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	# only handle string like types
	if type != TYPE_STRING and type != TYPE_STRING_NAME:
		return false
	
	if hint_string == "scene":
		add_property_editor(name, scene_reference_editor.new())
		#add_custom_control()
		return true
	
	return false
