extends BattleEffectPersistent

func effect_interaction(_new_effect:BattleEffect,_context:CombatMechanics.Context) -> bool:
	return true

func tick(_unit:Unit):
	pass

func apply(context:CombatMechanics.Context) -> bool:
	for target:Unit in context.target_units:
		target.active_effects[self as BattleEffectPersistent] = lifetime
	return true
