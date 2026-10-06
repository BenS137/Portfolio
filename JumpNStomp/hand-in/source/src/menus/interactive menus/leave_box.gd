extends PushableBox
class_name LeaveBox


var activated := false


func stomped(player: Player) -> void:

	# cant activate twice
	if activated:
		return

	# only stomp activates it
	if player.state_machine.current_state is not StompStatePlayer:
		return

	activated = true

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
	$RichTextLabel.visible = false


	player.move_data.bounce_up()


	# wait until break effect is visible
	await get_tree().create_timer(1.0).timeout


	# leave game
	get_tree().quit()
