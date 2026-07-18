@tool
extends HBoxContainer


signal started_holding_action
signal aborted_holding_action
signal completed_holding_action


var action_name: StringName: set = _set_action_name
@export var hold_time: float = 1.0: set = _set_hold_time

@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var action_icon: ActionIcon = %ActionIcon


var _current_held_time: float = 0.0
var _inv_hold_time: float = 1.0


func _ready() -> void:
	set_process(false)


func _input(event: InputEvent) -> void:
	if action_name.is_empty():
		return
	
	if event.is_action_pressed(action_name):
		started_holding_action.emit()
		set_process(true)
		_current_held_time = 0
		progress_bar.value = 0
		print("started")
	elif event.is_action_released(action_name) and _current_held_time < hold_time:
		aborted_holding_action.emit()
		set_process(false)
		_current_held_time = 0
		progress_bar.value = 0
		print("stopped")


func _process(delta: float) -> void:
	_current_held_time += delta
	progress_bar.value = clampf(_current_held_time * _inv_hold_time, 0.0, 1.0) * progress_bar.max_value
	
	if _current_held_time >= hold_time:
		set_process(false)
		_current_held_time = 0
		progress_bar.value = 0
		completed_holding_action.emit()
		print("completed")


func _set_hold_time(p_hold_time: float) -> void:
	hold_time = maxf(0.001, p_hold_time)
	_inv_hold_time = 1.0 / p_hold_time


func _set_action_name(p_action_name: StringName) -> void:
	action_name = p_action_name
	
	if not is_node_ready():
		await ready
	
	action_icon.action_name = p_action_name


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	var actions = []
	for prop in ProjectSettings.get_property_list():
		var prop_name:String = prop.get("name", "")
		if prop_name.begins_with('input/'):
			prop_name = prop_name.replace('input/', '') 
			prop_name = prop_name.substr(0, prop_name.find("."))
			if not actions.has(prop_name):
				actions.append(prop_name)
	
	properties.append({
		"name": "action_name",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM_SUGGESTION,
		"hint_string": ",".join(actions),
	})
	
	return properties
