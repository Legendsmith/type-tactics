extends BattleEffectPersistent

func check(other_effect:BattleEffect,_type:StringName) -> bool:
	return not other_effect is DamageEffect
