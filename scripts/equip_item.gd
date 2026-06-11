class_name EquipItem
extends Node
## Where can this be worn?
@export var valid_locations:Array[StringName]
## Bonuses, if any
@export var bonuses:Dictionary[Unit.Attribute,int]

@export var granted_techniques:Array[BattleTechnique]

@export var battle_start_effect:Resource

func setup():
	owner.recalculate_bonus.connect()
	owner.known_moves.append_array(granted_techniques)

func apply_bonus():
	for key:Unit.Attribute in bonuses.keys():
		owner.attribute_bonus[key] += bonuses[key]

func apply_technique():
	for tech:BattleTechnique in granted_techniques:
		owner.technique_charges[tech] = tech.max_charges

func unequip(unit:Unit = owner):
	for tech:BattleTechnique in granted_techniques:
		if tech not in unit.base_techniques:
			unit.technique_charges.erase(tech)
