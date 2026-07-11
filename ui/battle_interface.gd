extends GameInterface
static var unit_battle_display:PackedScene = load("uid://d18mrr8fdgs57")

func _ready() -> void:
	for unit:Unit in get_tree().get_nodes_in_group(Unit.UNIT_GROUP):
		on_unit_added(unit)

func on_unit_added(new_unit:Unit):
	var new_display:Control = unit_battle_display.instantiate()
	if new_unit.control_type == Constants.PLAYER_GROUP:
		%PlayerContainer.add_child(new_display)
	else:
		%EnemyContainer.add_child(new_display)
	new_display.set_unit(new_unit)
