@tool
extends "res://world/tiles_hex/hex.gd"

func update_color():
	var parent: TileMapLayer = get_parent()
	var new_color = parent.tile_set.get_terrain_color(terrain_set, terrain).lightened(0.1)
	color = new_color
	$WallTop.color = new_color
