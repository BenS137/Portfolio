extends Area2D

@onready
var box := get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	# check if it is even monitoring 
	# could be theat the collision component 
	# didnt switched it back on after wrapping player
	if not monitoring:
		return 
		
	for body in get_overlapping_bodies():
		pass
		#handle_other_body_entered(body)



func handle_other_body_entered (player: Player) -> void:

	# checks if the attacker is in the stomp state
	# only bounces the attacker if not in stomp state
	if player.state_machine.current_state is StompStatePlayer:
		pass
	else:
		player.move_data.bounce_up()
		
