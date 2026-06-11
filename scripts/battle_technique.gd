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

func execute() -> bool:
	return true
