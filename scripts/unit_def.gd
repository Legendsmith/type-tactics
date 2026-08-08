class_name UnitDef
extends Resource

@export var display_name:String
@export var unit_name:String
@export var twitch_name:String = ""
@export var dialogic_timeline:DialogicTimeline
@export var default_faction:StringName = &"opponent"
@export var portrait:Texture2D
@export var sprite:Texture2D
@export var overworld_sprite:Texture2D
@export var types:Array[StringName]
@export var ability:UnitAbility
@export var base_techniques:Array[BattleTechnique]
@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
## Overworld attack power. Only matters if no techniques are defined such as for mascots.
@export var overworld_power:float = 80
@export var max_equip:int = 2
@export var description:String
@export var default_desired_rank:int = 0
@export var equipment:Array[EquipItem] = []
@export var overworld_speed_base:float = 192

func get_modified_overworld_speed():
	return overworld_speed_base + (attribute_base[Unit.Attribute.SPEED]/100)-1

func get_overworld_power():
	if base_techniques.size():
		var power:float = 0
		var total_charges = base_techniques.reduce(func(accum,tech:BattleTechnique):
			return accum + tech.max_charges
		)
		for tech:BattleTechnique in base_techniques:
			power += tech.power * (tech.max_charges/total_charges)
		return roundf(power)
	else:
		return overworld_power
		