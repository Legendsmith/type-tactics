extends Node
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
signal activate_grid(coordinates:Vector2i)

#var map:Dictionary[Vector2i,Node2D]
