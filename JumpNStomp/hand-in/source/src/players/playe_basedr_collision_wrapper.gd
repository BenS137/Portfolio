extends Area2D

func _on_body_exited(body: Node2D) -> void:
	#only wrap player
	if body is CharacterBody2D:
		var screen_width := get_viewport_rect().size.x
		
		# calculate new x, with glabel position
		var target_x := wrapf(body.global_position.x, 0, screen_width)
		
		# make a new vector
		var new_global_pos := Vector2(target_x, body.global_position.y)
		
		# makes sure the teleport doesnt glitch while calculating physics
		body.call_deferred("set_global_position", new_global_pos)
