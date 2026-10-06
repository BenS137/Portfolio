extends Node

@onready var countdown_label := $CountdownLabel

var countdown_time := 4


func _ready() -> void:
	
	countdown_label.add_theme_font_override("font", Global.FONT_MICRO_5)
	countdown_label.add_theme_font_size_override("font_size", 150)

	start_countdown()
	
	start_countdown()


func start_countdown() -> void:
	var players = get_tree().get_nodes_in_group("player")

	for player in players:
		player.set_stomp_cooldown_shader(0.0)
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)

	if not players.is_empty():
		players[0].sound_machine.play_sound("countdown")

	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO!"
	await get_tree().create_timer(1.0).timeout

	countdown_label.text = ""

	for player in players:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)
