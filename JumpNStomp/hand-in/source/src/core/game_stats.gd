## constants and variables like player_stats, only for the game

extends Node

@onready
var player := owner as Player

const TARGET_SCORE: int = 10

var costum_target_score : int = 10
var game_mode: String = "normal"
var rounds : int = 3
var timer_enabled : bool = false
var respawn_delay : float = 1.5
