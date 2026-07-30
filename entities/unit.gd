class_name Unit
extends Node2D
signal recalculate_bonus
signal hp_changed(new_hp:int)
signal update()
const MIN_MODIFIER:int = -6
const MAX_MODIFIER:int = 6
const UNIT_GROUP := &"units"
const MAX_EQUIP:int = 2

enum Attribute {
	HP, ATTACK, DEFENSE, SPECIAL_ATTACK, SPECIAL_DEFENSE, SPEED, SIZE
}

class TurnAction:
	var technique:BattleTechnique
	var target:Variant
	var owner:Unit
	func _init(init_owner:Unit, init_technique=load("uid://dagu5nkeqlqr4")) -> void: ## init technique default is none.
		owner = init_owner
		technique = init_technique
	func create_context() -> CombatMechanics.Context:
		var ctx:CombatMechanics.Context = CombatMechanics.Context.new()
		ctx.source = owner
		if target is Vector2i:
			ctx.target_location = target
		elif target is Unit:
			ctx.target_units.append(target)
		else:
			target = owner #self target fallback? For now.
		return ctx
	func complete_turn():
		owner.technique_charges[technique] -= CombatMechanics.charge_usage(technique,owner.types)

@export var unit_definition:UnitDef
@export var display_name:String = "Combatant"
@export var subtitle:String = ""
@export var types:Array[StringName] = []
@export var base_techniques:Array[BattleTechnique]
@export var battle_sprite:Texture2D
@export var ability:UnitAbility
@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
@export var attribute_bonus:PackedInt32Array = [0,0,0,0,0,0,0]
@export var attribute_modifier:PackedInt32Array = [0,0,0,0,0,0,0]
@export var equipped_items:Array[EquipItem]
var _max_equip:int = 2
var dirty_attributes:bool = false

@export var hp:int:
	set(new):
		if new < hp:
			print_debug("%s recieved %s damage" % [self.name,hp-new])
		hp = clampi(new,0,get_attribute(Attribute.HP))
		hp_changed.emit(hp)

var max_hp:int:
	get:
		return get_attribute(Attribute.HP)

var technique_charges:Dictionary[BattleTechnique,int]
var active_effects:Dictionary[BattleEffectPersistent,int] = {}
@export var control_type:StringName = Constants.PLAYER_GROUP

@export_flags("Targetable", "Active") var battle_flags:int = 11

@onready var default_action = TurnAction.new(self, load("uid://dagu5nkeqlqr4"))
@onready var next_action:TurnAction = default_action

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
	for item:EquipItem in equipped_items: ## Equipped items
		var ctx:=CombatMechanics.Context.new()
		ctx.target_units[0] = self
		item.battle_start_effect.apply(ctx)

func equip_item(item:EquipItem)->bool:
	if equipped_items.size() >= _max_equip:
		return false
	else:
		equipped_items.append(item)
		item.on_equip(self)
		return true

func unequip_item(item:EquipItem):
	item.on_unequip(self)
	equipped_items.erase(item)

func serialize_attributes(attribute_array:Array):
	var serialized_dict:Dictionary = {}
	for i in range(attribute_array.size()):
		serialized_dict[Attribute.keys()[i]] = attribute_array[i]
	return serialized_dict

#endregion 
#region Setup, Items and Healing/Refresh
func _ready():
	add_to_group(UNIT_GROUP)


func battle_setup():
	if not get_parent() is Battlefield:
		return
	call_bonuses()
	#get_tree().current_scene.new_turn.connect(on_new_turn)
	#get_tree().current_scene.finalize_turn.connect(on_finalize_turn)
	$Area2D.body_entered.connect(func():
		add_to_group(CombatMechanics.TARGET_GROUP)
	)
	$Area2D.body_exited.connect(func():
		remove_from_group(CombatMechanics.TARGET_GROUP)
	)

func refresh_hp():
	hp = CombatMechanics.calc_attribute(attribute_base[Attribute.HP] + attribute_bonus[Attribute.HP],attribute_modifier[Attribute.HP])

## Refreshes all charges in the charges of techniques in the Base Techniques array.
func refresh_charges():
	for tech:BattleTechnique in base_techniques:
		technique_charges[tech] = tech.max_charges

func full_refresh():
	refresh_hp()
	refresh_charges()
#endregion 

#region Damage

func recieve_damage(damage:int):
	hp = hp - damage

#endregion

#region Techniques
func get_technique_uses() -> Dictionary:
	var technique_usages:Dictionary[BattleTechnique,int]
	for tech:BattleTechnique in technique_charges:
		technique_usages[tech] = technique_charges[tech]/CombatMechanics.charge_usage(tech,types)
	return technique_usages

func queue_technique(tech:BattleTechnique) -> bool:
	var charge_usage:int = CombatMechanics.charge_usage(tech,types)
	var action:TurnAction = TurnAction.new(self)
	if technique_charges[tech] >= charge_usage:
		action.technique = tech
		next_action = action
		update.emit()
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

func create_from_unit_def(def:UnitDef) -> Unit:
	unit_definition=def
	display_name = def.unit_name
	_max_equip = def.max_equip
	%MainSprite.texture = def.sprite
	types = def.types
	#ability = def.ability
	base_techniques = def.base_techniques.duplicate()
	attribute_base = def.attribute_base.duplicate()
	return self

func battle_animation(animation_name:StringName) -> AnimationPlayer:
	if not get_parent() is Battlefield:
		return
	$AnimationPlayer.play(animation_name)
	return $AnimationPlayer

func _exit_tree() -> void:
	remove_from_group(CombatMechanics.TARGET_GROUP)
