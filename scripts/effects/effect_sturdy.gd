extends BattleEffectPersistent

func effect_interaction(new_effect:BattleEffect,context:CombatMechanics.Context) -> bool:
	return true

func tick(unit:Unit):
	if unit.hp == 0:
		unit.hp = 1

func apply(context:CombatMechanics.Context) -> bool:
	for target:Unit in context.target_units:
		target.active_effects[self as BattleEffectPersistent] = lifetime
	return true
