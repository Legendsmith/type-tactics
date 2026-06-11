class_name AttackTechnique
extends BattleTechnique
@export var power:int = 100
@export var base:Units.Attribute = Units.Attribute.ATTACK
@export var target:Units.Attribute = Units.Attribute.DEFENSE

func execute() -> bool:
	return true
