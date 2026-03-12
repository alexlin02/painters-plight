extends Node2D

@export var player_index: int = 1
@export var start_position: Vector2i = Vector2i(0,0)

@onready var turn_manager = $"../../TurnManager"
@onready var grid_manager = $"../../GridManager"

var grid_pos: Vector2i
var move_range: int = 1
var color_inventory: Array = []
var move_charges: Array = []

func _ready():
	grid_pos = start_position
	print("player ", player_index, " starting at ", grid_pos)
	position = grid_manager.grid_to_world(grid_pos.x, grid_pos.y)
	grid_manager.grid[grid_pos.x][grid_pos.y]["occupant"] = self
	
func move(direction: Vector2i):
	var steps = move_range
	var target = grid_pos
	
	for i in range(steps):
		var next = target + direction
		
		if not grid_manager.is_cell_free(next.x, next.y):
			break
			
		# Out of bounds check
		if direction.x !=0 and direction.y != 0:
			if not grid_manager.is_in_bounds(target.x + direction.x, target.y) or not grid_manager.is_in_bounds(target.x, target.y + direction.y):
				break
		target = next
		
	if target == grid_pos:
		return false
			
	grid_manager.grid[grid_pos.x][grid_pos.y]["occupant"] = null
	grid_pos = target
	grid_manager.grid[grid_pos.x][grid_pos.y]["occupant"] = self
	position = grid_manager.grid_to_world(grid_pos.x, grid_pos.y)
	return true
		
func submit(action_type: String, data: Dictionary = {}):
	var action = {"type": action_type}
	action.merge(data)
	turn_manager.submit_action(player_index, action)
