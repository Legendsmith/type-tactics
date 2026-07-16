## Base class for battle techniques. This executes the code that functions on the user or the target
class_name BattleTechnique
extends Resource

const NONE_ACTION := "none"

@export var icon:Texture2D
@export var display_name:String = ""
@export var technique_name:String
@export var description:String
@export var type: StringName = &""
## actual uses are half this.
@export var max_charges: int = 8
@export var tags:Array[StringName] = []
@export var valid_target:CombatMechanics.TargetTypes
@export var power:int = 100
@export var effects:Array[BattleEffect]
## Depletes a charge when the move activates, regardless of if it hits. If false it only depletes a charge if it hits.
@export var deplete_on_activate:bool = true

@export var pattern: AttackPatternResource

func activate(context:CombatMechanics.Context):
	#var success:bool = target.execute_new_effect(user, effect, type)
	#if success or deplete_on_activate:
	#	user.technique_charges[self] -= charge_usage
	context.effect_params[&"power"] += power
	for effect:BattleEffect in effects:
		effect.apply(context)
