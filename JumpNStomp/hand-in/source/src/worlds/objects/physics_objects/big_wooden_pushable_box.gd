## a destroyable box
## colliding check is in movement data component in player
## and is handled with get collider

extends PushableBox
class_name BigPushableBox

var big_box_life : int = 3

# plays when player is stomping the box,  if he isnt, just stand on it
func stomped(player: Player) -> void:
	
	# ignore other states when inter acting with it
	if player.state_machine.current_state is not StompStatePlayer:
		return

	
	# check if player is in stomp state and box has no life
	if (player.state_machine.current_state is StompStatePlayer 
	and big_box_life == 0
	):
		
		# play particle animation
		box_vfx.visible = true
		box_vfx.restart()
		box_vfx.emitting = true
		
		# bounce up when stomping
	
		player.velocity.y = player.stats.NO_STOMP_BOUNCE_VELOCITY
		player.velocity.x = randf_range(
			-player.stats.NO_KILL_BOUNCE_OFF_RANGE,
			player.stats.NO_KILL_BOUNCE_OFF_RANGE
			)
			
		box_texture.visible = false
		await get_tree().create_timer(box_vfx.lifetime).timeout
		queue_free()
	
	# when stomping box it should be damaged when having still live
	elif (player.state_machine.current_state is StompStatePlayer 
	and big_box_life > 0
	):
		big_box_life -= 1
	
	
