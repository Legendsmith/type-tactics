extends BattleEffectPersistent
func _init() -> void:
	effect_type = &"block_damage"

func apply(context:CombatMechanics.Context):
	var any_success:bool = false
	for effect:BattleEffectPersistent in context.source.active_effects.keys():
		effect.effect_interaction(self,context)

	for target:Unit in context.target_units:
		var passed:bool = false
		for persistent_effect:BattleEffectPersistent in target.active_effects.keys():
			passed = persistent_effect.effect_interaction(self,context)
		if passed:
			var _key:BattleEffectPersistent = self as BattleEffectPersistent
			target.active_effects[_key] = lifetime
	return any_success

func tick(unit:Unit):
	unit.active_effects.erase(self)

func effect_interaction(new_effect:BattleEffect,_context:CombatMechanics.Context) -> bool:
	return not new_effect.effect_type == &"inflict_damage"
