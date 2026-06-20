class_name Unit
extends Node
signal recalculate_bonus
signal damage_recieved
const MIN_MODIFIER:int = -6
const MAX_MODIFIER:int = 6
const UNIT_GROUP := &"units"

enum Attribute {
	HP, ATTACK, DEFENSE, SPECIAL_ATTACK, SPECIAL_DEFENSE, SPEED, SIZE
}

class TurnAction:
	var technique:BattleTechnique
	var target:Variant
	var owner:Unit
	func _init(init_technique=null) -> void:
		technique = init_technique
	func activate():
		if is_instance_valid(target) and target.is_inside_tree():
			technique.activate(owner,target,CombatMechanics.charge_usage(technique,owner.types))

@export var unit_name:String = "Combatant"
@export var types:Array[StringName] = []
@export var base_techniques:Array[BattleTechnique]

@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
@export var attribute_bonus:PackedInt32Array = [0,0,0,0,0,0,0]
@export var attribute_modifier:PackedInt32Array = [0,0,0,0,0,0,0]

@export var hp:int:
	set(new):
		if new < hp:
			damage_recieved.emit()
			print_debug("%s recieved %s damage" % [self.name,hp-new])
		hp = clampi(new,0, get_attribute(Attribute.HP))

var technique_charges:Dictionary[BattleTechnique,int]

var next_action:TurnAction
var default_action = TurnAction.new(load("uid://dagu5nkeqlqr4"))

var control_type:StringName = &"player"

@export_flags("Targetable", "Active") var battle_flags:int = 11

@warning_ignore_start("integer_division")


#region Attributes
## Get attribute by its enum index. This is the normal way to retrieve an attribute.
func get_attribute(attribute_idx:Attribute, modified:bool=true) -> int:
	if modified:
		return CombatMechanics.calc_attribute(attribute_base[attribute_idx] + attribute_bonus[attribute_idx],attribute_modifier[attribute_idx])
	else:
		return attribute_base[attribute_idx] + attribute_bonus[attribute_idx]

## Unit's attack. Get returns the modified value. Set sets the modifier. Use the attributes array for direct access.
var attack:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.ATTACK] + attribute_bonus[Attribute.ATTACK],attribute_modifier[Attribute.ATTACK])
	set(new_mod):
		attribute_modifier[Attribute.ATTACK] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)
## Unit's defense. Get returns the modified value. Set sets the modifier. Use the attributes array for direct access.
var defense:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.DEFENSE] + attribute_bonus[Attribute.DEFENSE],attribute_modifier[Attribute.DEFENSE])
	set(new_mod):
		attribute_modifier[Attribute.DEFENSE] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)
## Unit's special_attack. Get returns the modified value. Set sets the modifier (-6 to +6). Use the attributes array for direct access.
var special_attack:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.SPECIAL_ATTACK] + attribute_bonus[Attribute.SPECIAL_ATTACK],attribute_modifier[Attribute.SPECIAL_ATTACK])
	set(new_mod):
		attribute_modifier[Attribute.SPECIAL_ATTACK] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)
## Unit's special_defense. Get returns the modified value. Set sets the modifier. Use the attributes array for direct access.
var special_defense:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.SPECIAL_DEFENSE] + attribute_bonus[Attribute.SPECIAL_DEFENSE],attribute_modifier[Attribute.SPECIAL_DEFENSE])
	set(new_mod):
		attribute_modifier[Attribute.SPECIAL_DEFENSE] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)
## Unit's speed. Get returns the modified value. Set sets the modifier. Use the attributes array for direct access.
var speed:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.SPEED] + attribute_bonus[Attribute.SPEED],attribute_modifier[Attribute.SPEED])
	set(new_mod):
		attribute_modifier[Attribute.SPEED] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)
## Unit's size. Get returns the modified value. Set sets the modifier. Use the attributes array for direct access.
var size:int:
	get:
		return CombatMechanics.calc_attribute(attribute_base[Attribute.SIZE] + attribute_bonus[Attribute.SIZE],attribute_modifier[Attribute.SIZE])
	set(new_mod):
		attribute_modifier[Attribute.SIZE] = clampi(new_mod,MIN_MODIFIER,MAX_MODIFIER)


func call_bonuses():
	attribute_bonus.fill(0)
	recalculate_bonus.emit()


func serialize_attributes(attribte_array:Array):
	var serialized_dict:Dictionary = {}
	for i in range(0,7):
		serialized_dict[Attribute.keys()[i]] = attribte_array[i]
	return serialized_dict

#endregion 
#region Setup and Healing/Refresh
func _ready():
	add_to_group(UNIT_GROUP)


func battle_setup():
	call_bonuses()
	get_tree().current_scene.new_turn.connect(on_new_turn)
	get_tree().current_scene.finalize_turn.connect(on_finalize_turn)

func refresh_hp():
	hp = CombatMechanics.calc_attribute(attribute_base[Attribute.HP] + attribute_bonus[Attribute.HP],attribute_modifier[Attribute.HP])

func refresh_charges():
	for tech:BattleTechnique in base_techniques:
		technique_charges[tech] = tech.max_charges

func full_refresh():
	refresh_hp()
	refresh_charges()
#endregion 

#region Techniques
func get_technique_uses() -> Dictionary:
	var technique_usages:Dictionary[BattleTechnique,int]
	for tech:BattleTechnique in technique_charges:
		technique_usages[tech] = technique_charges[tech]/CombatMechanics.charge_usage(tech,types)
	return technique_usages

func queue_technique(tech:BattleTechnique) -> bool:
	var charge_usage:int = CombatMechanics.charge_usage(tech,types)
	var action:TurnAction = TurnAction.new()
	if technique_charges[tech] >= charge_usage:
		action.technique = tech
		action.owner = self
		next_action = action
		return true
	else:
		return false
#endregion
#region Turns
func on_new_turn() -> void:
	next_action = default_action

func on_finalize_turn() -> void:
	if next_action.technique_name == BattleTechnique.NONE_ACTION and control_type == Constants.PLAYER_GROUP:
		var data:Dictionary = {"alert":GameInterface.Alert.NONE_ACTION,"source":self,"zoom":true}
		GameManager.game_interface.alert(data)
		get_tree().current_scene.turn_ready = false

#endregion
#region Damage

#endregion
