extends Node



var game_over : bool = false
var is_in_lobby : bool = false

var player_1_score : int = 0
var player_2_score : int = 0

var timer_enabled : bool = false
var timer_length : int = 0
var has_started := false


const FONT_MICRO_5: FontFile = preload(
	"res://hand-in/docs/Micro_5/Micro5-Regular.ttf"
	
	)

const FONT_TINY_5: FontFile = preload(#
	"res://hand-in/docs/Tiny5/Tiny5-Regular.ttf"
	
	)



# selected character ids
var player1_character: int = 0
var player2_character: int = 1

var selected_map_scene = "res://src/worlds/maps/world_wrap_test_flat.tscn"
