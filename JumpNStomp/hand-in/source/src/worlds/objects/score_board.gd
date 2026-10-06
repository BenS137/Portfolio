## shows the score and handles the simple win text.

class_name ScoreBoard
extends RichTextLabel

const LOBBY_SCENE := "res://src/menus/interactive menus/Lobby.tscn"

var default_task_text : String = "PROTECT HEAD!"
var can_return_to_menu := false


func _ready() -> void:
	# connect signals only once when scoreboard enters the game
	GameState.score_changed.connect(update_score)
	GameState.game_won.connect(_on_game_won)

	# show score once when match starts
	update_score()


func _process(_delta: float) -> void:
	# when game is won, dont overwrite win text
	if can_return_to_menu:
		return

	# timer changes every frame, so update score text while timer is on
	if Global.timer_enabled:
		update_score()


func update_score() -> void:
	# normal game state, pause can not return to lobby yet
	can_return_to_menu = false

	# default text in the middle
	var middle_text := default_task_text

	# if timer is enabled, show timer instead
	if Global.timer_enabled:
		middle_text = GameState.get_timer_text()

	# update scoreboard text
	text = "%d | %s | %d" % [
		Global.player_1_score,
		middle_text,
		Global.player_2_score
	]


func _on_game_won(message: String) -> void:
	# game is finished, allow pause to return to lobby
	can_return_to_menu = true

	# show winner text
	text = message 


func _unhandled_input(event: InputEvent) -> void:
	# only return to lobby when game is already won
	if not can_return_to_menu:
		return

	# only react to pause input
	if not event.is_action_pressed("pause"):
		return

	# reset game and go back to lobby
	GameState.reset()
	get_tree().change_scene_to_file(LOBBY_SCENE)
