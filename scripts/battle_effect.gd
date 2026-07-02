## Base class for all battle effects including damage. Every technique has an effect.
class_name BattleEffect
extends Resource

@export var function_name:StringName
@export var effect_type:StringName = &"inflict_damage"
@export var power:int = 100
@export var base_attribute:Unit.Attribute = Unit.Attribute.ATTACK
@export var target_attribute:Unit.Attribute = Unit.Attribute.DEFENSE

var effect:Callable
var type:StringName
func _init() -> void:
	effect = Callable.create(self,effect_type)
	print_debug(effect)

func execute(source:Unit,target:Node) -> bool:
	return effect.call(source,target)

func check(_other_effect:BattleEffect,_type:StringName) -> bool:
	return true

func inflict_damage(source:Unit,target:Node) -> bool:
	var damage = CombatMechanics.calc_damage(source.get_attribute(base_attribute),target.get_attribute(target_attribute),power)
	target.hp -= damage
	return true

func block_damage(other_effect:BattleEffect):
	return not other_effect.effect_type == &"inflict_damage"
