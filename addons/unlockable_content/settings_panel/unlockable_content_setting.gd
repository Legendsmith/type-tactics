@tool
extends Control

const CATEGORY_TAB = preload("res://addons/unlockable_content/settings_panel/category_tab.tscn")

@onready var settings_tab_container: TabContainer = %SettingTabContainer
@onready var general_settings := $"SettingTabContainer/General Settings"

var category_tabs: Array[Control] = []

func _ready() -> void:
	general_settings.category_list_updated.connect(_rebuild_categories)
	
	_rebuild_categories()


func _rebuild_categories() -> void:
	for category_tab in category_tabs:
		category_tab.name = "removed"
		category_tab.queue_free()
	
	category_tabs.clear()
	
	for category_info in UnlockableContent.database._category_infos:
		var category_tab: Control = _build_category(category_info)
		settings_tab_container.add_child(category_tab)
		category_tabs.append(category_tab)


func _build_category(category_info: Dictionary) -> Control:
	if not Engine.is_editor_hint():
		push_warning("cannot use category outside editor context.")
		var dummy := Control.new()
		dummy.name = category_info[&"category_name"].capitalize()
		return dummy
	
	var tab_node := CATEGORY_TAB.instantiate()
	tab_node._category_info = category_info
	
	var tab_name: String = category_info[&"category_name"]
	tab_node.name = tab_name.capitalize()
	
	return tab_node
