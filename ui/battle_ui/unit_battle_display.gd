extends Control

var unit:Unit:
	set = set_unit

func set_unit(new_unit:Unit):
	if is_instance_valid(unit):
		unit.hp_changed.disconnect(%HpBar.on_update)
		unit.update.disconnect(on_update)
	unit = new_unit
	%NameLabel.text = unit.display_name
	%HpBar.max_value = unit.get_attribute(Unit.Attribute.HP)
	%HpBar.value = unit.hp
	unit.hp_changed.connect(%HpBar.on_update)
	%ActionLabel.visible = unit.control_type == Constants.PLAYER_GROUP
	unit.update.connect(on_update)
	on_update()

func on_update():
	%ActionLabel.text = unit.next_action.technique.technique_name
