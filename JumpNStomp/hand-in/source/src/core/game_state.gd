## tracks the state of the game
## this includes things like the score of the players and who is the winner

extends Node

signal score_changed
signal game_won(winner_text: String)

var timer_start_ms: int = 0
var timer_length_ms: int = 0
var time_left_ms: int = 0

var timer_running : bool = false

func add_point_for_dead_player(dead_player_name: String) -> void:
	print("ADD POINT because dead:", dead_player_name)
	if Global.game_over:
		return

	if dead_player_name == "Player1":
		Global.player_2_score += 1
	elif dead_player_name == "Player2":
		Global.player_1_score += 1

	score_changed.emit()
	check_for_winner()

# who won
func check_for_winner() -> void:
	if Global.player_1_score >= GameStats.TARGET_SCORE:
		Global.game_over = true
		timer_running = false
		game_won.emit("Player 1 wins")
		await get_tree().create_timer(3.0).timeout
		TransitionManager.transition_to_scene("res://hand-in/source/src/menus/interactive menus/Lobby.tscn")

	if Global.player_2_score >= GameStats.TARGET_SCORE:
		Global.game_over = true
		timer_running = false
		game_won.emit("Player 2 wins")
		await get_tree().create_timer(3.0).timeout
		TransitionManager.transition_to_scene("res://hand-in/source/src/menus/interactive menus/Lobby.tscn")

# reset on staring new game
func reset() -> void:
	Global.game_over = false
	Global.player_1_score = 0
	Global.player_2_score = 0
	timer_start_ms = 0
	timer_length_ms = 0
	time_left_ms = 0
	timer_running = false
	set_timer()
	score_changed.emit()

# set timer
func set_timer() -> void:
	#check if timer is enabled
	if not Global.timer_enabled:
		return
	
	# activate timer 
	await get_tree().create_timer(4.0).timeout
	timer_running = true
	
	# we set the timer in milliseconds
	timer_start_ms = Time.get_ticks_msec()
	
	# set the timer to the time player set
	timer_length_ms = Global.timer_length * 60000
	time_left_ms = timer_length_ms

# count timer
func _process(_delta: float) -> void:
	# if no timer enabled stop here
	if not Global.timer_enabled:
		return

	# stop if no timer is running
	if not timer_running:
		return

	if Global.game_over:
		return
	
	# count down timer
	var passed_ms := Time.get_ticks_msec() - timer_start_ms
	time_left_ms = max(0, timer_length_ms - passed_ms)

	if time_left_ms <= 0:
		timer_running = false
		Global.game_over = true
		finish_timer_game()

# we get the min, secs and millisecs
# returning a string 

func get_timer_text() -> String:
	var minutes := int(time_left_ms / 60000)
	var seconds := int(time_left_ms / 1000) % 60
	var milliseconds := time_left_ms % 1000
	
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

# timer finished, decide who won
func finish_timer_game() -> void:
	if Global.player_1_score > Global.player_2_score:
		game_won.emit("Player 1 wins")
	elif Global.player_2_score > Global.player_1_score:
		game_won.emit("Player 2 wins")
	else:
		game_won.emit("Draw")
