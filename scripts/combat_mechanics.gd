class_name CombatMechanics
const NOTYPE_CHARGE_USE := 4
const DUAL_TYPE_CHARGE_USE := 3
const MONOTYPE_CHARGE_USE := 2


enum TargetTypes {
	SELF,NOT_SELF,ENEMY,ALLY,TILE,ANY
}

## Attribute modifier scale, ranges from -6 to +6.
const MODIFIER: Dictionary[int, float] = {
	-6: 2.0 / 8.0,
	-5: 2.0 / 7.0,
	-4: 2.0 / 6.0,
	-3: 2.0 / 5.0,
	-2: 2.0 / 4.0,
	-1: 2.0 / 3.0,
	0: 1.0,
	1: 1.5,
	2: 2.0,
	3: 2.5,
	4: 3.0,
	5: 3.5,
	6: 4
	}

## Used for accuracy differences usually from elevation.
const ACCURACY: Array = [
	3.0 / 4.0, 3.0 / 5.0, 3.0 / 6.0,
]

@warning_ignore_start("integer_division")

static func calc_attribute(attribute: int, modifier: int) -> int:
	return int(attribute * MODIFIER[clampi(modifier, -6, 6)])

static func charge_usage(technique: BattleTechnique, types: Array[StringName]) -> int:
	var type_match: bool = technique.type in types
	if type_match and types.size() == 1:
		return MONOTYPE_CHARGE_USE
	elif type_match:
		return DUAL_TYPE_CHARGE_USE
	else:
		return NOTYPE_CHARGE_USE

static func calc_damage(attack:int,defense:int, power:int) -> int:
	return (attack/defense) * power

static func process_unit_effects(turn_idx:int, unit:Unit): 
	for effect:BattleEffectPersistent in unit.active_effects.keys():
		if effect.lifetime + unit.active_effects[effect] < turn_idx:
			unit.active_effects.erase(effect)
		else:
			effect.tick(unit)
	
