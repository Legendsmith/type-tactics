extends Node
@export var actor:Unit
@export var target:Unit

func _ready() -> void:
	if actor:
		actor.full_refresh()
	if target:
		target.full_refresh()
	await get_tree().current_scene.ready
	await get_tree().create_timer(0.2).timeout
	on_take_turn()

func on_take_turn():
	actor.queue_technique(actor.base_techniques[0])
	actor.next_action.target = target
	var ctx:CombatMechanics.Context = actor.next_action.create_context()
	actor.next_action.technique.activate(ctx)
	actor.on_new_turn()
