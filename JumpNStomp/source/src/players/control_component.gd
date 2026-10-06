## handles the input action names for one player.
## player 1 uses wasd, player 2 uses arrow keys.

extends Node
class_name ControlComponent

@export var left_action := "LeftPlayer1"
@export var right_action := "RightPlayer1"
@export var jump_action := "JumpPlayer1"
@export var stomp_action := "StompPlayer1"

const WINDOW_TAB_LENGTH_IN_MS = 500

var time_since_last_tab = -2 * WINDOW_TAB_LENGTH_IN_MS
# gives each player a number, to remember sprite and assign the right controls
# is made in player.gd
func set_player_number(player_number: int) -> void:
	var control_number := str(player_number)

	left_action = "LeftPlayer" + control_number
	right_action = "RightPlayer" + control_number
	jump_action = "JumpPlayer" + control_number
	stomp_action = "StompPlayer" + control_number


# basic moveset
func get_x_direction() -> float:
	return Input.get_axis(left_action, right_action)


func is_left_pressed() -> bool:
	return Input.is_action_pressed(left_action)


func is_right_pressed() -> bool:
	return Input.is_action_pressed(right_action)


func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed(jump_action)


func is_jump_pressed() -> bool:
	return Input.is_action_pressed(jump_action)


func is_jump_just_released() -> bool:
	return Input.is_action_just_released(jump_action)


func is_stomp_just_pressed() -> bool:
	return Input.is_action_just_pressed(stomp_action)


func is_stomp_pressed() -> bool:
	return Input.is_action_pressed(stomp_action)



## getter für advanced movesets
#func get_just_pressed_x_direction() -> int:
	#if Input.is_action_just_pressed("move_right"):
		#return 1
#
	#if Input.is_action_just_pressed("move_left"):
		#return -1
#
	#return 0
	
	
# for the sprite turn delay we need to know the direction
# gets also used in several other things like
# breaking, stop glide, etc
func has_horizontal_input() -> bool:
	var input_x : bool = false
	if is_right_pressed() or is_left_pressed():
		input_x = true
	return get_x_direction() != 0.0 and input_x



# get double tab direction for horizontal input 
# we can easily connect with the move_data


#func get_double_tab_direction_horizontal(move_data: MovementDataComponent) -> int:
	#var direction := get_just_pressed_x_direction()
	#
	#if direction == 0:
		#return 0
	#
	#if direction == move_data.
