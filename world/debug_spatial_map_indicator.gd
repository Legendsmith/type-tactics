## Helper object for drawing the Spatial Hash grid in a World2D.

extends Node2D

func _draw() -> void:

	draw_grid(31)

func draw_grid(length:int) -> void:
	# This is the spatial hashmap grid.
	for i in range(-length, length):
		#row
		var multiplied:int = i * SpatialHash.SPATIAL_HASH_SIZE
		# y/Rows. Lines are horizontal, measures vertical
		draw_dashed_line(
			Vector2(-SpatialHash.SPATIAL_HASH_SIZE * length, multiplied),
			Vector2(SpatialHash.SPATIAL_HASH_SIZE * length, multiplied),
			Color.GOLD,
			-1.0,
			12.0
		)
		# x/Columns. Lines are vertical, measures horizontal
		draw_dashed_line(
			Vector2(multiplied, -SpatialHash.SPATIAL_HASH_SIZE * length),
			Vector2(multiplied, SpatialHash.SPATIAL_HASH_SIZE * length),
			Color.LIGHT_BLUE,
			-1.0,
			12.0
		)
	
	var offset:Vector2 = Vector2.ONE * (SpatialHash.SPATIAL_HASH_SIZE/2)
	for i:int in range(0,length):
		for x:int in range(0,length):
			var ix:int = i * SpatialHash.SPATIAL_HASH_SIZE
			var xx:int = x * SpatialHash.SPATIAL_HASH_SIZE
			draw_string(ThemeDB.fallback_font, Vector2(ix,xx) + offset, "%d,%d" % [i,x], HORIZONTAL_ALIGNMENT_CENTER, -1, 48, Color.GOLD)
			#draw_string(ThemeDB.fallback_font, Vector2(-ix,-xx) + offset, str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.GOLD)
		