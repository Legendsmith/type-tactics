extends Node
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
signal activate_grid(coordinates:Vector2i)

var astar:AStar2D = AStar2D.new()
var last_astar_idx:int = 0
#var map:Dictionary[Vector2i,Node2D]

func _ready() -> void:
	pass

func reset_map():
	astar = AStar2D.new()

func on_activate_grid(coordinates:Vector2i):
	astar.add_point(last_astar_idx,coordinates,1)
	last_astar_idx +=1

func link_grid(from:Vector2,to:Vector2,bidirection:bool=true):
	pass
