class_name AttackTechnique
extends BattleTechnique
@export var power:int = 100
@export var base:CombatMechanics.Attribute = CombatMechanics.Attribute.ATTACK
@export var target:CombatMechanics.Attribute = CombatMechanics.Attribute.DEFENSE

func execute() -> bool:
	return true
