extends PushableBox
class_name CharacterBox


func stomped(player: Player) -> void:
		

	if player.state_machine.current_state is not StompStatePlayer:
		return
	sound_machine = player.sound_machine

	if sound_machine:
		sound_machine.play_sound("select")
		
	player.move_data.bounce_up()

	if player._get_player_number() == 1:
		Global.player1_character += 1

		if Global.player1_character >= PlayerCharacterLibrary.CHARACTER_SHEETS.size():
			Global.player1_character = 0

		_apply_character_to_player(player, Global.player1_character)

	else:
		Global.player2_character += 1

		if Global.player2_character >= PlayerCharacterLibrary.CHARACTER_SHEETS.size():
			Global.player2_character = 0

		_apply_character_to_player(player, Global.player2_character)

	await get_tree().create_timer(0.25).timeout

# call the 
func _apply_character_to_player(
	player: Player, 
	character_index: int
	) -> void:
	player.player_sprite.sprite_frames = PlayerCharacterLibrary.create_sprite_frames(
		player.player_sprite.sprite_frames,
		character_index
	)

	player.player_sprite.play("Idle")
