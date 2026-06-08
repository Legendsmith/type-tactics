extends EditorProperty


var scene_picker: EditorResourcePicker
var open_scene_button: Button

var scene_id: String

func _init() -> void:
	scene_picker = EditorResourcePicker.new()
	#scene_picker.toggle_mode = true
	scene_picker.base_type = "PackedScene"
	scene_picker.resource_selected.connect(_scene_selected)
	scene_picker.resource_changed.connect(_resource_changed)
	
	add_child(scene_picker)
	add_focusable(scene_picker)
	
	
	open_scene_button = Button.new()
	open_scene_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	open_scene_button.text = "Open Scene"
	open_scene_button.visible = false
	open_scene_button.icon = EditorInterface.get_editor_theme().get_icon(&"PackedScene", &"EditorIcons")
	
	add_child(open_scene_button)
	set_bottom_editor(open_scene_button)


func _update_property() -> void:
	var new_scene_id: String = get_edited_object()[get_edited_property()]
	if new_scene_id == scene_id:
		return
	
	scene_id = new_scene_id
	
	if scene_id.is_empty():
		open_scene_button.disabled = true
		return
	
	var scene: PackedScene = load(scene_id) as PackedScene
	scene_picker.edited_resource = scene
	
	open_scene_button.disabled = false


func _resource_changed(resource: Resource) -> void:
	var scene: PackedScene = resource as PackedScene
	
	if scene:
		var uid: int = ResourceLoader.get_resource_uid(scene.resource_path)
		scene_id = ResourceUID.id_to_text(uid) if ResourceUID.has_id(uid) else ""
		
		emit_changed(get_edited_property(), scene_id)


func _scene_selected(resource: Resource, inspect: bool) -> void:
	if inspect:
		EditorInterface.inspect_object.call_deferred(resource)
		return
	
	open_scene_button.visible = !open_scene_button.visible
