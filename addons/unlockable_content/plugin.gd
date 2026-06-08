@tool
extends EditorPlugin

const UNLOCKABLE_CONTENT_SETTING = preload("res://addons/unlockable_content/settings_panel/unlockable_content_setting.tscn")
const UC_NODE_NAME: String = "UnlockableContent"

var setting_control: Control

func _enable_plugin() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton(UC_NODE_NAME, "res://addons/unlockable_content/unlockable_content.gd")


func _enter_tree() -> void:
	setting_control = UNLOCKABLE_CONTENT_SETTING.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_control)


func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, setting_control)
	setting_control.queue_free()


func _disable_plugin() -> void:
	remove_autoload_singleton(UC_NODE_NAME)
