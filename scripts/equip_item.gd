class_name EquipItem
extends Resource
## Name of this Item
@export var display_name:String
## Where can this be worn?
@export var valid_locations:Array[StringName]
## Bonuses, if any
@export var bonuses:Dictionary[Unit.Attribute,int]

@export var granted_techniques:Array[BattleTechnique]

@export var battle_start_effect:Resource

func on_equip(unit:Unit):
	unit.recalculate_bonus.connect(apply_bonus)
	unit.known_moves.append_array(granted_techniques)

func apply_bonus(unit:Unit):
	for key:Unit.Attribute in bonuses.keys():
		unit.attribute_bonus[key] += bonuses[key]

func apply_technique(unit:Unit):
	for tech:BattleTechnique in granted_techniques:
		unit.technique_charges[tech] = tech.max_charges

func on_unequip(unit:Unit):
	for tech:BattleTechnique in granted_techniques:
		if tech not in unit.base_techniques:
			unit.technique_charges.erase(tech)
		unit.recalculate_bonus.disconnect(apply_bonus)
