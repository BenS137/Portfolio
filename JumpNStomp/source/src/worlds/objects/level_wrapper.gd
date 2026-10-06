extends Area2D

"""
looks if player leaver to the side, and teleports him to the opposite side
make this the size of the viewport window when making a new map!


got the inspo from a video of Coding Kook on Youtube
"""
#func _on_BoundaryNotifier_body_exited(body):
	#
	## get the window size
	#var rect_size = get_viewport_rect().size
	#
	## when player walks over right edge
	#if body.global_position.x < global_position.x - (rect_size.x / 2):
		#body.global_position.x += rect_size.x 
		#
	## when he walks out to the right
	#elif body.global_position.x > global_position.x + (rect_size.x / 2):
		#body.global_position.x -= rect_size.x
