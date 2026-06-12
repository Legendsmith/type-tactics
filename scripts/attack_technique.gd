class_name AttackTechnique
extends BattleTechnique
@export var power:int = 100
@export var base:Unit.Attribute = Unit.Attribute.ATTACK
@export var target:Unit.Attribute = Unit.Attribute.DEFENSE

func execute() -> bool:
	return true
