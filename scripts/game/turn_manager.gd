class_name TurnManager
extends Node

@onready var player1 = $"../Players/Player1"
@onready var player2 = $"../Players/Player2"

enum Phase {
	PLAYER_INPUT,
	RESOLUTION,
	COLOR_EFFECTS,
	TURN_END
}

var current_phase: Phase = Phase.PLAYER_INPUT
var player1_action = null
var player2_action = null

const rounds_to_win = 4
var player1_rounds: int = 0
var player2_rounds: int = 0

signal phase_changed(new_phase)
signal turn_resolved
signal round_won(player_index)
signal match_won(player_index)

func _ready() -> void:
	start_turn()

func start_turn():
	player1_action = null
	player2_action = null
	_set_phase(Phase.PLAYER_INPUT)
	
func submit_action(player_index: int, action: Dictionary) -> bool:
	if current_phase != Phase.PLAYER_INPUT:
		return false
	if player_index == 1 and player1_action != null:
		return false  # already submitted this turn
	if player_index == 2 and player2_action != null:
		return false
	if player_index == 1:
		player1_action = action
	elif player_index == 2:
		player2_action = action
	if player1_action != null and player2_action != null:
		_resolve_turn()
	return true
	
func _resolve_turn():
	_set_phase(Phase.RESOLUTION)

	# MOVEMENT RESOLVES FIRST
	var p1_target = player1.grid_pos
	var p2_target = player2.grid_pos

	if player1_action and player1_action["type"] == "move":
		p1_target = player1.grid_pos + player1_action["direction"]
	if player2_action and player2_action["type"] == "move":
		p2_target = player2.grid_pos + player2_action["direction"]

	if p1_target != p2_target:
		if player1_action and player1_action["type"] == "move":
			player1.move(player1_action["direction"])
		if player2_action and player2_action["type"] == "move":
			player2.move(player2_action["direction"])
			
	# ATTACKS RESOLVE LAST
	var p1_attacks = player1_action and player1_action["type"] == "attack"
	var p2_attacks = player2_action and player2_action["type"] == "attack"
	
	var p1_hits = p1_attacks and (player1.grid_pos + player1_action["direction"]) == player2.grid_pos
	var p2_hits = p2_attacks and (player2.grid_pos + player2_action["direction"]) == player1.grid_pos
	
	if p1_hits and p2_hits:
		pass
	elif p1_hits:
		if not (player2_action and player2_action["type"] == "block"):
			_award_round(1)
	elif p2_hits:
		if not (player1_action and player1_action["type"] == "block"):
			_award_round(2)

	_set_phase(Phase.COLOR_EFFECTS)
	_set_phase(Phase.TURN_END)
	emit_signal("turn_resolved")
	start_turn()
	
func _award_round(player_index: int):
	if player_index == 1:
		player1_rounds += 1
	elif player_index == 2:
		player2_rounds += 1
	
	emit_signal("round_won", player_index)
	if player1_rounds >= rounds_to_win or player2_rounds >= rounds_to_win:
		emit_signal("match_won", player_index)
	
	
func _set_phase(phase: Phase):                                                                  
	current_phase = phase
	emit_signal("phase_changed", phase)
