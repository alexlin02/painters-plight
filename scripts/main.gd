extends Node2D

@onready var grid_manager = $GridManager
@onready var turn_manager = $TurnManager
@onready var player1 = $"Players/Player1"
@onready var player2 = $"Players/Player2"

var rng = RandomNumberGenerator.new() 

func _ready():
	rng.seed = 12345
