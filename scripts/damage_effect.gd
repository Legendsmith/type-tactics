class_name DamageEffect
extends BattleEffect

@export var power:int = 100
@export var base_attribute:Unit.Attribute = Unit.Attribute.ATTACK
@export var target_attribute:Unit.Attribute = Unit.Attribute.DEFENSE

func execute(source:Unit,target:Node) -> bool:
	var damage = CombatMechanics.calc_damage(source.get_attribute(base_attribute),target.get_attribute(target_attribute),power)
	target.hp -= damage
	return true
