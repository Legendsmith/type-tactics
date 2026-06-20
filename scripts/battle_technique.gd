## Base class for battle techniques. This executes the code that functions on the user or the target
class_name BattleTechnique
extends Resource

const NONE_ACTION := "none"

@export var icon:Texture2D
@export var technique_name:String
@export var type: StringName = &""
## actual uses are half this.
@export var max_charges: int = 8
@export var tags:Array[StringName] = []
@export var valid_target:CombatMechanics.TargetTypes
@export var effect:BattleEffect
## Depletes a charge when the move activates, regardless of if it hits. If false it only depletes a charge if it hits.
@export var deplete_on_activate:bool = true


func activate(user:Unit,target:Node, charge_usage:int):
	var success = effect.execute(user,target)
	if success or deplete_on_activate: 
		user.technique_charges[self] -= charge_usage
