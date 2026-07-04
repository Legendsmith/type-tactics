class_name DamageEffect
extends BattleEffect

#@export var effect_type:StringName = "inflict_damage"
#@export var power:int = 100
#var type:StringName
@export var base_attribute:Unit.Attribute = Unit.Attribute.ATTACK
@export var target_attribute:Unit.Attribute = Unit.Attribute.DEFENSE
#
#func execute(source:Unit,target:Node) -> bool:
#	var damage = CombatMechanics.calc_damage(source.get_attribute(base_attribute),target.get_attribute(target_attribute),power)
#	target.hp -= damage
#	return true

func apply(context:CombatMechanics.Context):
	var any_success:bool = false
	#for effect:BattleEffectPersistent in context.source.active_effects.keys():
	#	effect.effect_interaction(self,context)

	for target:Unit in context.target_units:
		print_debug("Attempting to apply damage, from %s to %s" % [context.source,target])
		var min_hp = 0
		var passed:bool = true
		var damage = CombatMechanics.calc_damage(context.source.get_attribute(base_attribute),target.get_attribute(target_attribute),context.effect_params[&"power"])
		context.effect_params[&"damage"] = damage
		for persistent_effect:BattleEffectPersistent in target.active_effects.keys():
			passed = persistent_effect.effect_interaction(self,context)
			# This feels jank af but this is the logic for applying damage so it goes her\e.
			if persistent_effect.effect_type == &"sturdy" and target.hp == target.get_attribute(Unit.Attribute.HP):
				min_hp = 1
		if passed:
			print_debug("Damage is: ", damage)
			target.hp = max(min_hp,target.hp - damage)
			any_success = true
	return any_success
