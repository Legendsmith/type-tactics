## Base class for all battle effects including damage. Every technique has an effect.
class_name BattleEffect
extends Resource

func execute(_source:Unit,_target:Node) -> bool:
	return true

func check(_other_effect:BattleEffect,_type:StringName) -> bool:
	return true
