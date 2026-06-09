## Base class for battle techniques. This executes the code that functions on the user or the target
class_name BattleTechnique
extends Resource
@export var type: StringName = &""
## actual uses are half this.
@export var max_charges: int = 8
@export var tags:Array[StringName] = []

func execute() -> bool:
	return true
