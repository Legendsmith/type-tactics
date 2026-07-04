extends BattleEffectPersistent

func effect_interaction( new_effect:BattleEffect, context:CombatMechanics.Context) -> bool:
	for target:Unit in context.target_units:
		if new_effect.effect_type == &"inflict_damage" and target.hp >= target.max_hp:
			context[&"min_hp"] = 1
	return true

func tick(_unit:Unit):
	pass

func apply(context:CombatMechanics.Context) -> bool:
	for target:Unit in context.target_units:
		target.active_effects[self as BattleEffectPersistent] = lifetime
	return true
