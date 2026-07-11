## Base class for all battle effects including damage. Every technique has an effect.
@abstract
class_name BattleEffect
extends Resource
@export var effect_type:StringName = &"inflict_damage"

## Function carries out the effect.
@abstract func apply(context:CombatMechanics.Context) -> bool
