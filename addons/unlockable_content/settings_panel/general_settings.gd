@tool
extends PanelContainer

signal category_list_updated

@onready var add_category_button: Button = %AddCategoryButton
@onready var category_name_edit: UCValidatedLineEdit = %CategoryNameEdit
@onready var resource_type_options: OptionButton = %ResourceTypeOptions
@onready var category_list: VBoxContainer = %CategoryList

var _resource_types: Array[Dictionary]

func _ready() -> void:
	visibility_changed.connect(func () -> void:
		if visible:
			category_name_edit.text = ""
			resource_type_options.selected = -1
			add_category_button.disabled = true
			
			_update_resource_type_options()
	)
	
	category_name_edit.validation_succesful.connect(_handle_add_button)
	resource_type_options.item_selected.connect(_handle_add_button.unbind(1))
	add_category_button.pressed.connect(_on_add_category_pressed)
	
	_update_resource_type_options()
	_build_category_list()


func _build_category_list() -> void:
	for category_info in UnlockableContent.database._category_infos:
		_add_category_row(category_info)


func _add_category_row(category_info: Dictionary) -> void:
	var row: HBoxContainer = HBoxContainer.new()
		
	var remove_category_button: Button = Button.new()
	remove_category_button.text = "Remove"
	remove_category_button.pressed.connect(func () -> void:
		UnlockableContent.database._category_infos.erase(category_info)
		UnlockableContent.database.unlockable_content_store.erase(category_info[&"category_name"])
		row.queue_free()
		category_list_updated.emit()
		
		UnlockableContent.mark_dirty()
		#ResourceSaver.save(UnlockableContent.database)
	)
	row.add_child(remove_category_button)
	
	var category_label: Label = Label.new()
	category_label.text = category_info[&"category_name"]
	row.add_child(category_label)
	
	category_list.add_child(row)


func _update_resource_type_options() -> void:
	#var selected_index: int = resource_type_options.selected
	#var previously_selected_type: String = resource_type_options.get_item_text(selected_index) if selected_index != -1 else ""
	
	#var resource_types: PackedStringArray = ClassDB.get_inheriters_from_class(&"UnlockableResource") # I would love to use this >:(
	_resource_types = _get_inheriters_from_class(&"UnlockableResource")
	
	resource_type_options.clear()
	for resource_type_info: Dictionary in _resource_types:
		var resource_type: String = resource_type_info["class"]
		resource_type_options.add_item(resource_type)
		#if resource_type == previously_selected_type:
			#selected_index = resource_type_options.item_count - 1
	
	#resource_type_options.select(selected_index)


func _handle_add_button() -> void:
	add_category_button.disabled = (resource_type_options.selected == -1 or 
			category_name_edit.text.is_empty() or 
			UnlockableContent.database.unlockable_content_store.has(StringName(category_name_edit.text)))


func _on_add_category_pressed() -> void:
	var category_name: StringName = StringName(category_name_edit.text)
	var category_info: Dictionary = {
		&"category_name": category_name,
		&"resource_type_name": StringName(resource_type_options.get_item_text(resource_type_options.selected)),
		&"resource_script_uid": ResourceUID.id_to_text(ResourceLoader.get_resource_uid(_resource_types[resource_type_options.selected]["path"]))
	}
	UnlockableContent.database._category_infos.append(category_info)
	
	_add_category_row(category_info)
	
	var items: Array[UnlockableResource] = []
	UnlockableContent.database.unlockable_content_store.set(category_name, items)
	UnlockableContent.mark_dirty()
	#ResourceSaver.save(UnlockableContent.database)
	category_list_updated.emit()
	
	category_name_edit.text = ""


func _get_inheriters_from_class(base_class: StringName) -> Array[Dictionary]:
	var class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var results: Array[Dictionary] = []
	
	var base_map: Dictionary = {}
	for c in class_list:
		base_map[c["class"]] = c["base"]
	
	for c in class_list:
		if _inherits_from(c["class"], base_class, base_map):
			results.append(c)
	
	return results


func _inherits_from(cn: String, base_class: String, base_map: Dictionary) -> bool:
	var current = cn
	while base_map.has(current):
		if base_map[current] == base_class:
			return true
		current = base_map[current]
	return false
