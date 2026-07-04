class_name DamageEffect
extends BattleEffect

#@export var effect_type:StringName = "inflict_damage"
#@export var power:int = 100
#var type:StringName
@export var base_attribute: Unit.Attribute = Unit.Attribute.ATTACK
@export var target_attribute: Unit.Attribute = Unit.Attribute.DEFENSE
#
#func execute(source:Unit,target:Node) -> bool:
#	var damage = CombatMechanics.calc_damage(source.get_attribute(base_attribute),target.get_attribute(target_attribute),power)
#	target.hp -= damage
#	return true

func apply(context: CombatMechanics.Context):
	var any_success: bool = false
	#for effect:BattleEffectPersistent in context.source.active_effects.keys():
	#	effect.effect_interaction(self,context)
	context.effect_params[&"base_attribute"] = base_attribute
	context.effect_params[&"target_attribute"] = target_attribute
	for persistent_effect: BattleEffectPersistent in context.source.active_effects.keys():
		persistent_effect.effect_interaction_source(self,context)
	for target: Unit in context.target_units:
		## Duplicate the context so it can be modified by other abilities without changing the base context.
		var target_context: CombatMechanics.Context = context.duplicate()
		target_context.target_units = [target]
		var passed: bool = true
		for persistent_effect: BattleEffectPersistent in target.active_effects.keys():
			passed = persistent_effect.effect_interaction(self, target_context)
		var damage = CombatMechanics.calc_damage(context.source.get_attribute(base_attribute), target.get_attribute(target_attribute), target_context.effect_params[&"power"])
		print_debug("Attempting to apply damage, from %s to %s" % [context.source, target])
		target_context.effect_params[&"damage"] = damage
		if passed:
			print_debug("Damage is: ", damage)
			target.hp = max(target_context[&"min_hp"], target.hp - damage)
			any_success = true
	return any_success
