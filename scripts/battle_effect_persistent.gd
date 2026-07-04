@abstract
class_name BattleEffectPersistent
extends BattleEffect
@export var lifetime:int = -1

## Used for when effects are trying to apply themselves. Should return true if this effect allows the new effect to apply itself.
@abstract func effect_interaction(new_effect:BattleEffect,context:CombatMechanics.Context) -> bool

## End of turn ability tick. For effects such as DoTs this is when they should deal damage.
@abstract func tick(unit:Unit)

func exit(unit:Unit):
	pass

## For effects that modify other outgoing effects.
func effect_interaction_source(_new_effect:BattleEffect,_context:CombatMechanics.Context) -> bool:
	return true
