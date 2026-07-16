class_name UnitDef
extends Resource

@export var unit_name:String
@export var twitch_name:String = ""
@export var portrait:Texture2D
@export var sprite:Texture2D
@export var types:Array[StringName]
@export var ability:UnitAbility
@export var base_techniques:Array[BattleTechnique]
@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
@export var max_equip:int = 2
@export var description:String
