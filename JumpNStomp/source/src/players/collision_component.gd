## handles player collision shapes, stomp areas and screen wrapping.
## the wrapper works by making a duplicate of the player on each side of the viewport
## deleting the old duplications when not on the screen

extends Node
class_name CollisionComponent

@onready 
var player := owner as Player
@onready
var stats := $"../PlayerStats" as PlayerStats


# find all CollisionShape2D nodes at the moment this function is called.
# this also catches the extra collision shapes from the screen wrap copies.
func set_collision_disabled(disabled: bool) -> void:
	for collision_shape in _get_player_collision_shapes():
		if collision_shape == null:
			continue

		# CollisionShape2D nodes use disabled to stop real body collision.
		collision_shape.set_deferred("disabled", disabled)

	# Area2D nodes use monitoring/monitorable instead of disabled.
	# this turns off stomp detection and being detected by other areas.
	for collision_area in _get_player_collision_areas():
		if collision_area == null:
			continue

		collision_area.set_deferred("monitoring", not disabled)
		collision_area.set_deferred("monitorable", not disabled)

# we need to keep track of all the collision shapes, for the wrap effect to work 
func _get_player_collision_shapes() -> Array[CollisionShape2D]:
	var shapes: Array[CollisionShape2D] = []

	# recursive true means: search inside children, grandchildren, etc.
	# owned false means: also find runtime duplicated nodes from WrapComponent.
	# "*" means nodes with any character or none
	for child in player.find_children("*", "CollisionShape2D", true, false):
		var shape := child as CollisionShape2D
		if shape != null:
			shapes.append(shape)

	return shapes

# get all the collision areas the player has
func _get_player_collision_areas() -> Array[Area2D]:
	var areas: Array[Area2D] = []

	# Area2D is used for sensors like StompArea.
	for child in player.find_children("*", "Area2D", true, false):
		var area := child as Area2D
		if area != null:
			areas.append(area)

	return areas

# we need to handle this in a seperate script, because godot acts funny when wrapping physics whith wrapf().
func handle_screen_wrap() -> void:

	if player == null:
		return

	var screen_width := player.get_viewport_rect().size.x
	player.move_data.did_wrap = false

	# checks if player leaves left.
	if player.global_position.x < 0:
		player.global_position.x += screen_width
		player.move_data.did_wrap = true

	# checks if player leaves right.
	elif player.global_position.x > screen_width:
		player.global_position.x -= screen_width
		player.move_data.did_wrap = true

	# forces Godot to take hitbox with it.
	if player.move_data.did_wrap:
		player.force_update_transform()

# to make the player interact with other physics bodys
# we need to call this function after move_and_slide()
func handle_player_collisions() -> void:
	# we get the number of collisions in 1 given frame
	for collision_index in player.get_slide_collision_count():
		
		# every counted collision gets its own collision handled
		var collision := player.get_slide_collision(collision_index)
		var collider := collision.get_collider()
		
		# handles rigid bodies like boxes 
		# note that we push it away by getting the opposite of the normal vector multiplying it with the push force
		# push fore can be changed in the player stats
		if collider as RigidBody2D:
			
			# when we collide with a box, we want to be able to destroy it by stomping
			var pushable_box := collider as PushableBox
			
			# map box
			var map_selection_box := collider as MapSelectionBox
		
			# timer box
			var timer_box := collider as TimerBox

			# not ideal, but the logic check if player is in stomp state is in the stomped function wich is locatet in the box
			if pushable_box:
				pushable_box.stomped(player)
				
			# not ideal to have this seperate i know, but we have to finish this asap
			if map_selection_box:
				map_selection_box.map_change_on_stomp(player)
			
			# timer box
			if timer_box:
				timer_box.timer_stomped(player)
			
			
			# push happens here!
			collider.apply_central_impulse(-collision.get_normal() * stats.PUSH_FORCE)

		# handles other players
		var other_player := collider as Player
		
		if collider == other_player:
			if player.state_machine.current_state is FallStatePlayer:
					player.move_data.bounce_up()
					
			if (player.state_machine.current_state is StompStatePlayer
			or player.state_machine.current_state is BrakingStatePlayer
			or player.state_machine.current_state is IdleStatePlayer
			and Global.is_in_lobby
			):
				player.move_data.bounce_up()
		
		# skips other bodies like floors
		if other_player == null:
			continue
	
		# skip yourself 
		if other_player == player:
			continue
		
		# cant stomp yourself
		if player.state_machine.current_state is StompStatePlayer:
			
			other_player.death_component.stomped_by(player)
			continue

		# stomp happens here
		if other_player.state_machine.current_state is StompStatePlayer:
			player.death_component.stomped_by(other_player)
			continue
