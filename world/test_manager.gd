extends Node
@export var actor:Unit
@export var target:Unit

func _ready() -> void:
	actor.full_refresh()
	target.full_refresh()

func on_take_turn():
	actor.queue_technique(actor.base_techniques[0])
	actor.next_action.target = target
	actor.next_action.activate()
	actor.on_new_turn()
