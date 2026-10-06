## a destroyable box
## colliding check is in movement data component in player
## and is handled with get collider

extends RigidBody2D
class_name PushableBox

@onready var box_vfx := $BoxVfx as GPUParticles2D
@onready var box_texture := $BoxTexture as Sprite2D
@onready var box_collision := $BoxCollision as CollisionShape2D
var sound_machine: SoundMachine


# plays when player is stomping the box,  if he isnt, just stand on it
func stomped(player: Player) -> void:
	
	# check if player is in stomp state
	if player.state_machine.current_state is StompStatePlayer:
		sound_machine = player.sound_machine
		
		# play particle animation
		box_vfx.visible = true
		box_vfx.restart()
		box_vfx.emitting = true
		
		if sound_machine:
			sound_machine.play_sound("explosion_box")
		
		# bounce up when stomping
		player.velocity.y = player.stats.NO_STOMP_BOUNCE_VELOCITY
		player.velocity.x = randf_range(
			-player.stats.NO_KILL_BOUNCE_OFF_RANGE,
			player.stats.NO_KILL_BOUNCE_OFF_RANGE
		)
		
		box_texture.visible = false
		await get_tree().create_timer(box_vfx.lifetime).timeout
		queue_free()
