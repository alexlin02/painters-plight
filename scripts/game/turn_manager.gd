extends Node

enum Phase {
	PLAYER_INPUT,
	RESOLUTION,
	COLOR_EFFECTS,
	TURN_END
}

var current_phase: Phase = Phase.PLAYER_INPUT
var player1_action = null
var player2_action = null

signal phase_changed(new_phase)
signal turn_resolved

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
	
	_set_phase(Phase.COLOR_EFFECTS)
	
	_set_phase(Phase.TURN_END)
	emit_signal("turn_resolved")
	start_turn()
	
func _set_phase(phase: Phase):
	current_phase = phase
	emit_signal("phase_changed")
