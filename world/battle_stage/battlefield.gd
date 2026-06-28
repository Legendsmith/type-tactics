class_name Battlefield
extends Node2D

@export var dimensions: Vector2i = Vector2i(3, 3):
	set(val):
		dimensions = val.maxi(1)
		print(dimensions)

## 
@export var invert_rank: int

@export var terain_layer: TileMapLayer
