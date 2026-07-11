extends BattleEffect
@export var target_attribute:Unit.Attribute
@export_range(0.01,1,0.001) var chance_
@export_range(-6,6,1) var stages:int = 1

func apply(context:CombatMechanics.Context) -> bool:
	context.source.attribute_modifier[target_attribute] += stages
	return true
