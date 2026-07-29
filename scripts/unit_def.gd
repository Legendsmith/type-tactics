class_name UnitDef
extends Resource

@export var unit_name:String
@export var twitch_name:String = ""
@export var default_faction:StringName = &"opponent"
@export var portrait:Texture2D
@export var sprite:Texture2D
@export var overworld_sprite:Texture2D
@export var types:Array[StringName]
@export var ability:UnitAbility
@export var base_techniques:Array[BattleTechnique]
@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
@export var max_equip:int = 2
@export var description:String
@export var default_desired_rank:int = 0
@export var equipment:Array[EquipItem] = []
@export var overworld_speed_base:float = 192

func get_modified_overworld_speed():
	return overworld_speed_base + (attribute_base[Unit.Attribute.SPEED]/100)-1
