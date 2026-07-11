class_name UnitDef
extends Resource

@export var unit_name:String
@export var twitch_name:String = ""
@export var sprite:Texture2D
@export var types:Array[StringName]
@export var ability:Resource
@export var base_techniques:Array[BattleTechnique]
@export var attribute_base:PackedInt32Array = [100,100,100,100,100,100,100]
