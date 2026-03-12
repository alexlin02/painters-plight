extends Node

@onready var grid_manager = $"../GridManager"
@onready var turn_manager = $"../TurnManager"
@onready var player1 = $"../Players/Player1"
@onready var player2 = $"../Players/Player2"

var player1_submitted: bool = false
var player2_submitted: bool = false

var active_player: int = 1

func _ready():
	turn_manager.turn_resolved.connect(_on_turn_resolved)
	turn_manager.phase_changed.connect(_on_phase_changed)
	
func _unhandled_input(event: InputEvent) -> void:
	if turn_manager.current_phase != TurnManager.Phase.PLAYER_INPUT:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(event.position)
			
func _handle_click(screen_pos: Vector2):
	var grid_pos = grid_manager.world_to_grid(screen_pos)
	
	if not grid_manager.is_in_bounds(grid_pos.x, grid_pos.y):
		return
	
	print("clicked tile: ", grid_pos)
	
	var current_player = _get_active_player()
	if current_player == null:
		print("no active player")
		return
		
	var direction = grid_pos - current_player.grid_pos
	
	direction = _clamp_direction(direction, current_player.move_range)
	
	if direction == Vector2i(0,0):
		return
	
	print("submitting move: ", direction)
	_mark_submitted(active_player)
	current_player.submit("move", {"direction": direction})
	
func _get_active_player():
	if active_player == 1 and not player1_submitted:
		return player1
	if active_player == 2 and not player2_submitted:
		return player2
	return null
	
func _clamp_direction(direction: Vector2i, move_range: int) -> Vector2i:
	var cx = clamp(direction.x, -move_range, move_range)
	var cy = clamp(direction.y, -move_range, move_range)
	return Vector2i(cx, cy)
	
func _mark_submitted(player_index: int):
	print("marking submitted for: ", player_index, ". active_player before: ", active_player)
	if player_index == 1:
		player1_submitted = true
		active_player = 2
	elif player_index == 2:
		player2_submitted = true
		active_player = 0
	print("active_player after: ", active_player)

func _on_turn_resolved():
	player1_submitted = false
	player2_submitted = false
	active_player = 1
	
@warning_ignore("unused_parameter")
func _on_phase_changed(phase):
	pass
	
