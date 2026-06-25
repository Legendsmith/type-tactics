extends Node3D
@export var width:int = 3
@export var grid:Dictionary[Vector2i,Node3D]


func _ready() -> void:
	var children:Array[Node] = get_children()
	var last:int = 0
	for child:Node3D in children:
		var key:Vector2i = Vector2i
		grid


