extends PushableBox
class_name StartBox

# get the lobby variables
@onready
var lobby := get_parent().get_parent() as Lobby



var activated := false

func _ready() -> void:
	pass
	
	# show the map on box
	
# gets called by player colission component
# when get collider == PushableBox
func stomped(player: Player) -> void:
	
	# cant start twice in one stomp
	if activated:
		return

	# ignores not stomps as a second check
	if player.state_machine.current_state is not StompStatePlayer:
		return
	
	sound_machine = player.sound_machine

	if sound_machine:
		sound_machine.play_sound("hit")


	# play particle animation
	box_vfx.visible = true
	box_vfx.restart()
	box_vfx.emitting = true
		
	box_texture.visible = false
#	await get_tree().create_timer(box_vfx.lifetime).timeout

	activated = true

	_on_start_button_pressed()
	player.move_data.bounce_up()

	queue_free()

# pass the settings to global and start map
func _on_start_button_pressed() -> void:
	Global.timer_enabled = lobby.timer_enabled
	Global.timer_length = lobby.timer_minutes
	Global.selected_map_scene = MapPathBus.maps[lobby.selected_map_index]["scene"]

	TransitionManager.transition_to_scene(Global.selected_map_scene)
	music_manager.play_intro_and_loop(
		preload("res://hand-in/source/src/audio/MusicManager/gameplay/fighting_theme_intro.wav"),
		preload("res://hand-in/source/src/audio/MusicManager/gameplay/fighting_theme.wav")
	)
