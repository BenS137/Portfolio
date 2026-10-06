extends RigidBody2D

@onready var box_vfx := $BoxVfx as GPUParticles2D
@onready var box_texture := $BoxTexture as Sprite2D
@onready var box_collision := $BoxCollision as CollisionShape2D
@onready var stomp_area_box := $BoxStompArea as Area2D


func _ready() -> void:
	stomp_area_box.body_entered.connect(_on_box_stomp_area_body_entered)


func _on_box_stomp_area_body_entered(body: Node2D) -> void:
	# cast every body as a player
	var player := body as Player
	
	# stop here if its not a player
	if player == null:
			return

	# start destruction
	stomped(player)

# plays when player is stomping the box,  if he isnt, just stand on it
func stomped(player: Player) -> void:

	if player.state_machine.current_state is StompStatePlayer:
		box_vfx.visible = true
		box_vfx.restart()
		box_vfx.emitting = true
		
		player.velocity.y = player.stats.NO_STOMP_BOUNCE_VELOCITY
		player.velocity.x = randf_range(
			-player.stats.NO_KILL_BOUNCE_OFF_RANGE,
			player.stats.NO_KILL_BOUNCE_OFF_RANGE
		)
		
		box_texture.visible = false
		await get_tree().create_timer(box_vfx.lifetime).timeout
		queue_free()
