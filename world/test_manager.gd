extends Node
@export var actor:Unit
@export var target:Unit

func _ready() -> void:
	if actor:
		actor.full_refresh()
	if target:
		target.full_refresh()

func on_take_turn():
	actor.queue_technique(actor.base_techniques[0])
	actor.next_action.target = target
	actor.next_action.activate()
	actor.on_new_turn()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("area clicked")
