extends GameInterface

const UNIT_BATTLE_DISPLAY := preload("uid://d18mrr8fdgs57")
const MAX_TOASTS: int = 5

@onready var combat_log: MarginContainer = %CombatLog
@onready var combat_log_container: VBoxContainer = %CombatLogContainer
@onready var toast_container: VBoxContainer = %ToastContainer

## Determines how long a toast notification will stay on screen before it is 
## automatically dismissed without user input.
@export_range(0.3, 1.0, 0.01, "hide_control", "or_greater") var toast_time_to_live: float = 5.0

# FIXME: add typing to this. right now it is templated for the next joe shmoe who ties things together.
var combat_system
var selected_unit: Unit
var highlighted_unit: Unit
var toast_queue: Array[Button] = []

var _combat_log_state: int = 0


func _ready() -> void:
	#FIXME: hook this onto a system that keeps track of the state of the combat.
	#		right now, no such system exists.
	combat_system = get_tree().get_first_node_in_group(&"combat_system")
	
	reset_combat_log_state()
	clear_all_toasts(true)


#func _ready() -> void:
	#for unit:Unit in get_tree().get_nodes_in_group(Unit.UNIT_GROUP):
		#on_unit_added(unit)
#
#func on_unit_added(new_unit:Unit):
	#var new_display:Control = UNIT_BATTLE_DISPLAY.instantiate()
	#if new_unit.control_type == Constants.PLAYER_GROUP:
		#%PlayerContainer.add_child(new_display)
	#else:
		#%EnemyContainer.add_child(new_display)
	#new_display.set_unit(new_unit)

# NOTICE: should the pause UI really be part of this UI?
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause_game"):
		get_tree().paused = !get_tree().paused
	get_viewport().set_input_as_handled()


func set_highlighted_unit(unit: Unit) -> void:
	if highlighted_unit == unit:
		return
	
	#TODO: Use effects to make it clear which unit is highlighted
	highlighted_unit = unit


func set_selected_unit(unit: Unit) -> void:
	if selected_unit == unit:
		return
	
	#TODO: use effect to make clear which unit is selected (glow? pulse? hue shift?)
	selected_unit = unit
	


func show_combat_log() -> void:
	build_combat_log()
	combat_log.show()


func hide_combat_log() -> void:
	combat_log.hide()


## Creates the combat log from a clean slate to display all events that happened in this skirmish.
func build_combat_log() -> void:
	# TODO: make this functional beyond being a template for later.
	var combat_log: Array = combat_system.get_combat_log()
	var incoming_combat_log_state = combat_log.size()
	
	#assert(incoming_combat_log_state >= _combat_log_state, "Unexpected combat state. combat log is out of sync")
	if _combat_log_state > incoming_combat_log_state:
		push_error("Unexpected combat state. combat log is out of sync! Flushing combat log")
		reset_combat_log_state()
	
	# Check if the combat log is in need for appending information.
	if _combat_log_state == incoming_combat_log_state:
		return
	
	# Append new log messages to the log container
	for index in range(_combat_log_state, incoming_combat_log_state):
		if index != 0:
			combat_log_container.add_child(HSeparator.new())
		
		var log_instance = combat_log[index]
		
		var log_label := RichTextLabel.new()
		log_label.bbcode_enabled = true
		log_label.fit_content = true
		log_label.text = _log_to_text(log_instance)
		combat_log_container.add_child(log_label)
	
	# update the tracked state in the UI
	_combat_log_state = incoming_combat_log_state


## Adds a toast notification on screen that can be dismissed by user input or by expiring. 
func add_toast(message: String, icon: Texture2D = null) -> void:
	# When there are too many toasts on screen, initiate removing the oldest live one.
	if toast_queue.size() >= MAX_TOASTS:
		dismiss_toast(toast_queue.back())
	
	var toast := Button.new()
	var toast_timer := Timer.new()
	
	toast.text = message
	toast.icon = icon
	
	toast_timer.one_shot = true
	
	toast.pressed.connect(dismiss_toast.bind(toast))
	toast_timer.timeout.connect(dismiss_toast.bind(toast))
	
	toast.add_child(toast_timer)
	toast_container.add_child(toast)
	toast_queue.push_front(toast)
	
	# TODO: add some form of smooth animation?
	
	toast_timer.start(toast_time_to_live)


## Removes a toast from screen.
func dismiss_toast(toast: Button) -> void:
	if toast.has_meta(&"dismissed"):
		return
	
	toast_queue.erase(toast)
	toast.set_meta(&"dismissed", true)
	# TODO: add dismiss animation?
	
	toast.queue_free()


#region Helpers

## Transforms a combat log instance into a string with BB code woven into it.
func _log_to_text(log_instance) -> String:
	assert(false, "not implemented")
	#TODO: implement this
	return ""


## Resets the internal tracked combat log state and clears any nodes in the log container.
func reset_combat_log_state() -> void:
	# flush the pre-existing log
	for child in combat_log_container.get_children():
		child.queue_free()
	
	_combat_log_state = 0


## Clears all visible toasts on screen. If done immediatly, it will skip 
## the standard dismissal process.
func clear_all_toasts(immediatly: bool = false):
	if immediatly:
		for toast in toast_container.get_children():
			toast.queue_free()
		toast_queue.clear()
	else:
		for toast in toast_queue:
			dismiss_toast.call_deferred(toast)

#endregion
