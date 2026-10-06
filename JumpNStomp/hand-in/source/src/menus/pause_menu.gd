extends Control

const LOBBY_SCENE := "res://hand-in/source/src/menus/interactive menus/Lobby.tscn"


func _ready():
	$Panel/CenterContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)
	$Panel/CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	$Panel/CenterContainer/VBoxContainer/ResumeButton.grab_focus()


func play_click_sound() -> void:
	var players = get_tree().get_nodes_in_group("player")

	if not players.is_empty():
		players[0].sound_machine.play_sound("click")


func _on_resume_button_pressed():
	play_click_sound()

	get_tree().paused = false
	queue_free()


func _on_quit_button_pressed():
	play_click_sound()

	await get_tree().create_timer(0.2).timeout

	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file(LOBBY_SCENE)
