extends Node2D

const GRID_WIDTH = 20
const GRID_HEIGHT = 12
const TILE_SIZE = 32

var grid = []

@onready var tilemap = $"../TileMap"

func _ready():
	_init_grid()
	queue_redraw()
	
func _init_grid():
	for i in range(GRID_WIDTH):
		grid.append([])
		for j in range(GRID_HEIGHT):
			grid[i].append({
				"color": null,
				"occupant": null,
				"effect": null
			})

# Grid Helpers
func grid_to_world(gx: int, gy: int):
	return Vector2(gx * TILE_SIZE + TILE_SIZE / 2.0, gy * TILE_SIZE + TILE_SIZE / 2.0)
	
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))

func is_in_bounds(gx: int, gy: int) -> bool:
	return gx >= 0 and gx < GRID_WIDTH and gy >= 0 and gy < GRID_HEIGHT
	
func is_cell_free(gx: int, gy: int) -> bool:
	return is_in_bounds(gx, gy) and grid[gx][gy]["occupant"] == null
	
# Painting
func paint_cell(gx: int, gy: int, color: String):
	if not is_in_bounds(gx, gy):
		return
	grid[gx][gy]["color"] = color
	_update_tile_visual(gx, gy, color)
	queue_redraw()

func clear_cell_color(gx: int, gy: int):
	if not is_in_bounds(gx, gy):
		return
	grid[gx][gy]["color"] = null
	_update_tile_visual(gx, gy, null)
	queue_redraw()

func get_cell_color(gx: int, gy: int) -> String:
	if not is_in_bounds(gx, gy):
		return ""
	return grid[gx][gy]["color"] if grid[gx][gy]["color"] != null else ""
	
@warning_ignore("unused_parameter")
func _update_tile_visual(gx: int, gy: int, color):		# Implement with visuals
	pass
	
func _color_string_to_color(color_name: String) -> Color:	# Fill out when choosing palette
	match color_name:
		"red": return Color(1,1,1,1)
		_: return Color(1,1,1,1)
		
# Placeholder grid and background
func _draw():
	# Define grid line color (soft pastel blue-grey, 50% transparent)
	var line_color = Color(0.8, 0.8, 0.9, 0.5)
	
	# Draw vertical lines (one per column boundary)
	for x in range(GRID_WIDTH + 1):
		draw_line(
			Vector2(x * TILE_SIZE, 0),
			Vector2(x * TILE_SIZE, GRID_HEIGHT * TILE_SIZE),
			line_color,
			1.0
		)
	
	# Draw horizontal lines (one per row boundary)
	for y in range(GRID_HEIGHT + 1):
		draw_line(
			Vector2(0, y * TILE_SIZE),
			Vector2(GRID_WIDTH * TILE_SIZE, y * TILE_SIZE),
			line_color,
			1.0
		)
	
	# Draw painted cells as filled colored rectangles
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var cell = grid[x][y]
			if cell["color"] != null:
				draw_rect(
					Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE),
					_color_string_to_color(cell["color"]),
					true
				)
				
func get_game_state() -> Dictionary:
	return {
		"grid": grid,
	}
