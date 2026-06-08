@tool
extends PanelContainer

@onready var content_list: ItemList = %ContentList
@onready var add_button: Button = %AddButton
@onready var remove_button: Button = %RemoveButton
@onready var move_up_button: Button = %MoveUpButton
@onready var move_down_button: Button = %MoveDownButton

var resource_inspector: EditorInspector
var _category_info: Dictionary: set = set_category_info
var _category_items: Array[UnlockableResource] = []
var _resource_script: GDScript


func _init() -> void:
	resource_inspector = EditorInspector.new()
	resource_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _ready() -> void:
	$HSplitContainer.add_child(resource_inspector)
	
	content_list.item_selected.connect(_on_item_selected)
	add_button.pressed.connect(_on_add_item_pressed)
	remove_button.pressed.connect(_on_remove_item_pressed)
	
	move_up_button.pressed.connect(_on_move_up_pressed)
	move_down_button.pressed.connect(_on_move_down_pressed)
	
	resource_inspector.property_edited.connect(_on_resource_property_edited)
	
	content_list.clear()
	for item: UnlockableResource in _category_items:
		var display_name: String = item._get_display_name()
		content_list.add_item(display_name if not display_name.is_empty() else "index: %d" % (content_list.item_count + 1), item._get_icon())


func set_category_info(category_info: Dictionary) -> void:
	_category_info = category_info
	_category_items = UnlockableContent.database.get_unlockable_category(category_info[&"category_name"])
	_resource_script = load(category_info[&"resource_script_uid"])


func _on_item_selected(index: int) -> void:
	assert(_category_items.size() > index, "selected item is out of range!")
	
	remove_button.disabled = false
	resource_inspector.edit(_category_items[index])
	
	move_up_button.disabled = index <= 0
	move_down_button.disabled = index == (_category_items.size() - 1)


func _on_add_item_pressed() -> void:
	var new_resource: UnlockableResource = _resource_script.new() as UnlockableResource
	var placeholder_name: String = "index: %d" % (content_list.item_count + 1)
	if new_resource._get_display_name_property_name() == &"resource_name":
		new_resource.resource_name = placeholder_name
	
	var index: int = content_list.add_item(placeholder_name)
	content_list.select(index)
	_category_items.append(new_resource)
	
	content_list.item_selected.emit(index)
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()


func _on_remove_item_pressed() -> void:
	var index: int = content_list.get_selected_items()[0]
	content_list.remove_item(index)
	_category_items.pop_at(index)
	
	remove_button.disabled = true
	resource_inspector.edit(null)
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()


func _on_move_up_pressed() -> void:
	var selected_index: int = content_list.get_selected_items()[0]
	var seleced_resource: UnlockableResource = _category_items[selected_index]
	
	# perform inplace swap
	_category_items[selected_index] = _category_items[selected_index - 1]
	_category_items[selected_index - 1] = seleced_resource
	
	content_list.move_item(selected_index, selected_index - 1)
	content_list.select(selected_index - 1)
	
	selected_index -= 1
	
	move_up_button.disabled = selected_index <= 0
	move_down_button.disabled = selected_index == (_category_items.size() - 1)
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()


func _on_move_down_pressed() -> void:
	var selected_index: int = content_list.get_selected_items()[0]
	var seleced_resource: UnlockableResource = _category_items[selected_index]
	
	# perform inplace swap
	_category_items[selected_index] = _category_items[selected_index + 1]
	_category_items[selected_index + 1] = seleced_resource
	
	content_list.move_item(selected_index, selected_index + 1)
	content_list.select(selected_index + 1)
	
	selected_index += 1
	
	move_up_button.disabled = selected_index <= 0
	move_down_button.disabled = selected_index == (_category_items.size() - 1)
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()


func _on_resource_property_edited(property: StringName) -> void:
	var selected_index: int = content_list.get_selected_items()[0]
	var seleced_resource: UnlockableResource = _category_items[selected_index]
	
	if property == seleced_resource._get_display_name_property_name():
		var display_name: String = seleced_resource._get_display_name()
		content_list.set_item_text(selected_index, display_name if not display_name.is_empty() else "index: %d" % (selected_index + 1))
	if property == seleced_resource._get_icon_property_name():
		content_list.set_item_icon(selected_index, seleced_resource._get_icon())
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()
