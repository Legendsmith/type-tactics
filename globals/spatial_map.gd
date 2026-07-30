extends Node
@warning_ignore_start("unused_signal")
signal request_hashmap_near(list: Array, coordinates: Vector2i)
signal request_hashmap_near_filter(list: Array, coordinates: Vector2i, method: StringName, method_value: Variant)
# Used to activate entities near this part of the map, usually when the player approaches.
signal activate_grid(coordinates:Vector2i)
signal link_request(overworld_link,coordinates_start:Vector2,coordinates_end:Vector2)
#var map:Dictionary[Vector2i,Node2D]
