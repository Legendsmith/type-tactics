@tool
extends PanelContainer

@onready var flag_group_selection_area: ItemList = %FlagGroupSelectionArea

var _selected_flag_group: int = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		if not is_node_ready():
			await ready
		prepare_flags()


func add_node_name(accum: Array, node: Node) -> Array:
	accum.append(node.name)
	return accum


func prepare_flags() -> void:
	flag_group_selection_area.clear()
	
	for flag_group_info: Dictionary in UnlockableContent.database._flag_collections_infos:
		flag_group_selection_area.add_item(flag_group_info[&"collection_name"])
	
	_update_flag_info_container()


func _on_add_flags_button_pressed() -> void:
	var flag_group: String = %FlagGroupName.text
	var flag_group_info: Dictionary = {
		&"collection_name": flag_group,
		&"max_flag": -1,
		&"flags": {}
	}
	UnlockableContent.database._flag_collections_infos.append(flag_group_info)
	UnlockableContent.database._flag_collections_infos_lookup.set(flag_group, flag_group_info)
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()
	var idx: int = flag_group_selection_area.add_item(flag_group)
	flag_group_selection_area.select(idx)
	_selected_flag_group = idx
	
	%AddFlagsGroupButton.disabled = true
	_update_flag_info_container()


func _on_remove_flag_group_button_pressed() -> void:
	var removed_group: Dictionary = UnlockableContent.database._flag_collections_infos.pop_at(_selected_flag_group)
	UnlockableContent.database._flag_collections_infos_lookup.erase(removed_group[&"collection_name"])
	flag_group_selection_area.remove_item(_selected_flag_group)
	_selected_flag_group = -1
	_update_flag_info_container()
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()


func _on_add_flag_button_pressed() -> void:
	var value_text: String = %AddFlagContainer/FlagValue.text
	var flag_group_info: Dictionary = UnlockableContent.database._flag_collections_infos[_selected_flag_group]
	
	var value: int
	if value_text.is_empty():
		value = flag_group_info[&"max_flag"] + 1
		flag_group_info[&"max_flag"] = value
	else:
		value = int(value_text)
		if value > flag_group_info[&"max_flag"]:
			flag_group_info[&"max_flag"] = value
	
	var flag_name: String = %AddFlagContainer/FlagNameEdit.text
	
	var flags: Dictionary = flag_group_info[&"flags"]
	flags.set(flag_name, value)
	
	%AddFlagContainer/FlagValue.text = ""
	%AddFlagContainer/FlagNameEdit.text = ""
	
	#ResourceSaver.save(UnlockableContent.database)
	UnlockableContent.mark_dirty()
	_update_flag_info_container()


func _update_flag_info_container() -> void:
	for child in %FlagInfo.get_children():
		child.queue_free()
	
	for child: Control in %FlagInfoContainer.get_children():
		child.visible= _selected_flag_group != -1
	
	if _selected_flag_group == -1:
		return
	
	var flag_group_info: Dictionary = UnlockableContent.database._flag_collections_infos[_selected_flag_group]
	
	var flag_infos := flag_group_info.get(&"flags") as Dictionary
	
	%AddFlagContainer/FlagNameEdit.text = ""
	%AddFlagContainer/FlagValue.text = ""
	%AddFlagContainer/AddFlagButton.disabled = true
	
	var value_sorted_flags = []
	for flag_name: String in flag_infos:
		value_sorted_flags.append([flag_name, flag_infos[flag_name]])
	
	value_sorted_flags.sort_custom(func(a, b) -> bool: return a[1] < b[1])
	
	for flag_kv_pair: Array in value_sorted_flags:
		var flag_name: String = flag_kv_pair[0]
		var row: HBoxContainer = HBoxContainer.new()
		%FlagInfo.add_child(row)
		
		var flag_name_edit: UCValidatedLineEdit = UCValidatedLineEdit.new()
		flag_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flag_name_edit.text = flag_name
		flag_name_edit.validation_succesful.connect(func () -> void:
			var v: int = flag_infos[flag_name_edit.old_text]
			flag_infos.erase(flag_name_edit.old_text)
			flag_infos.set(flag_name_edit.text, v)
			#ResourceSaver.save(UnlockableContent.database)
			UnlockableContent.mark_dirty()
		)
		row.add_child(flag_name_edit)
		
		var flag_value_edit: SpinBox = SpinBox.new()
		flag_value_edit.size_flags_horizontal = Control.SIZE_FILL
		flag_value_edit.value = flag_kv_pair[1]
		flag_value_edit.max_value = 9223372036854775807
		flag_value_edit.value_changed.connect(func (_v) -> void:
			flag_infos.set(flag_name_edit.text, int(flag_value_edit.value))
			_calculate_max_flag(flag_group_info)
			#ResourceSaver.save(UnlockableContent.database)
			UnlockableContent.mark_dirty()
		)
		row.add_child(flag_value_edit)
		
		var remove_flag_button: Button = Button.new()
		remove_flag_button.size_flags_horizontal = Control.SIZE_FILL
		remove_flag_button.text = "Remove"
		remove_flag_button.pressed.connect(func () -> void:
			flag_infos.erase(flag_name_edit.text)
			row.queue_free()
			#ResourceSaver.save(UnlockableContent.database)
			UnlockableContent.mark_dirty()
		)
		row.add_child(remove_flag_button)


func _on_flag_name_edit_text_changed() -> void:
	var flags: Dictionary = UnlockableContent.database._flag_collections_infos[_selected_flag_group][&"flags"]
	var flag_name: StringName = StringName(%AddFlagContainer/FlagNameEdit.text)
	%AddFlagContainer/AddFlagButton.disabled = flag_name.is_empty() or flags.has(flag_name)


func _on_flag_group_selection_area_item_selected(index: int) -> void:
	_selected_flag_group = index
	_update_flag_info_container()


func _calculate_max_flag(flag_group_info: Dictionary) -> void:
	var max_value: int = -1
	
	var flag_infos: Dictionary = flag_group_info[&"flags"]
	for flag_name: StringName in flag_infos:
		if flag_infos[flag_name] > max_value:
			max_value = flag_infos[flag_name]
	
	flag_group_info[&"max_flag"] = max_value


func _on_flag_group_name_validation_succesful() -> void:
	if %FlagGroupName.text.is_empty():
		%AddFlagsGroupButton.disabled = true
		return
	
	for info in UnlockableContent.database._flag_collections_infos:
		if info[&"collection_name"] == %FlagGroupName.text:
			%AddFlagsGroupButton.disabled = true
			return
	
	%AddFlagsGroupButton.disabled = false
