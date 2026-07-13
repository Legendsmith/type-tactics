@tool
extends Control

signal zoom_changed

const CELL_SIZE: int = 32
const GRID_COLOR: Color = Color(0.3, 0.3, 0.3)
const ORIGIN_COLOR: Color = Color.GOLD
const FILLED_COLOR: Color = Color(0.8, 0.2, 0.2)

var camera_position: Vector2 = Vector2.ZERO
var zoom: float = 1:
	set(value):
		zoom = value
		zoom_changed.emit()

var dragging: bool = false
var hovered_cell: Vector2i

var pattern: AttackPatternResource
var selected_cells: Dictionary[Vector2i, Object]

## Sets the pattern that has to be edited.
func set_pattern(pattern: AttackPatternResource) -> void:
	self.pattern = pattern
	
	selected_cells.clear()
	if pattern:
		reset_zoom()
		center_on_origin()
		
		for offset in pattern.offsets:
			selected_cells.set(offset, null)
	
	queue_redraw()

## Converts the grid coordinates into the 2d space coordinates.
func grid_to_world(cell: Vector2i) -> Vector2:
	return (Vector2(cell) - (Vector2.ONE * 0.5)) * CELL_SIZE

## Converts the 2d space coordinates into grid coordinates.
func world_to_grid(position: Vector2) -> Vector2i:
	var p = position + Vector2.ONE * CELL_SIZE * 0.5
	return Vector2i(
		floori(p.x / CELL_SIZE),
		floori(p.y / CELL_SIZE)
	)

## Converts the 2d space coordinates into dock space coordinates.
func world_to_screen(world: Vector2) -> Vector2:
	return ((world - camera_position) * zoom) + (size * 0.5)

## Converts the dock space coordinates to the 2d space coordinates
func screen_to_world(screen: Vector2) -> Vector2:
	return ((screen- (size * 0.5)) / zoom) + camera_position

func _draw() -> void:
	if pattern == null:
		return
	
	draw_selected_tiles()
	draw_grid()
	draw_origin()
	display_hovered_cell()

## Draws teh grid lines based on the current camera position and zoom level
func draw_grid() -> void:
	var top_left: Vector2i = screen_to_world(Vector2.ZERO)
	var bottom_right: Vector2i = screen_to_world(size)
	
	var first: Vector2i = world_to_grid(top_left)
	var last: Vector2i = world_to_grid(bottom_right)
	
	for x in range(first.x, last.x + 2):
		var screen = world_to_screen(Vector2((x - 0.5) * CELL_SIZE, 0))
		
		draw_line(
			Vector2(screen.x, 0),
			Vector2(screen.x, size.y),
			GRID_COLOR
		)

	for y in range(first.y, last.y + 2):
		var screen = world_to_screen(Vector2(0, (y - 0.5) * CELL_SIZE))
		
		draw_line(
			Vector2(0, screen.y),
			Vector2(size.x, screen.y),
			GRID_COLOR
		)

## Draws the currently selected tiles onto the grid.
func draw_selected_tiles() -> void:
	for cell in pattern.offsets:
		var screen = world_to_screen(grid_to_world(cell))

		draw_rect(
			Rect2(
				screen,
				Vector2.ONE * CELL_SIZE * zoom
			),
			FILLED_COLOR
		)

## Draws the marker for identifying the origin tile.
func draw_origin():
	draw_circle(
		world_to_screen(Vector2.ZERO), (CELL_SIZE * 0.25) * zoom, 
		ORIGIN_COLOR
	)

func _gui_input(event):
	if pattern == null:
		return
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					toggle_cell(event.position)
			
			MOUSE_BUTTON_MIDDLE:
				dragging = event.pressed
			
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					zoom *= 1.1
					queue_redraw()
			
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					zoom /= 1.1
					queue_redraw()
	
	elif event is InputEventMouseMotion:
		if dragging:
			camera_position -= event.relative / zoom
			queue_redraw()
		
		var world := screen_to_world(event.position)
		var cell := world_to_grid(world)
		
		if cell != hovered_cell:
			hovered_cell = cell
			queue_redraw()

## Toggle the state of the cell at the current mouse position opposite of it's previous state.
func toggle_cell(mouse_pos: Vector2):
	var world := screen_to_world(mouse_pos)
	var cell := world_to_grid(world)
	
	if selected_cells.has(cell):
		selected_cells.erase(cell)
	else:
		selected_cells.set(cell, null)
	
	var offsets := selected_cells.keys()
	offsets.sort()
	
	pattern.offsets = offsets
	
	pattern.emit_changed()
	
	queue_redraw()

func display_hovered_cell():
	draw_string(ThemeDB.fallback_font, Vector2(0, size.y), "%s" % [hovered_cell])

## Returns the canvas to the base position, centered around (0, 0)
func center_on_origin():
	camera_position = Vector2.ZERO
	queue_redraw()

## Resets the zoom back to the default value
func reset_zoom() -> void:
	zoom = 1.0
	queue_redraw()
