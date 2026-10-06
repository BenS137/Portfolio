
extends PlayerState
class_name IdleStatePlayer

@export
var fall_state: State
@export
var jump_state: State
@export
var stomp_state: State
@export
var run_state: State
@export
var duck_state: State
@export
var brake_state: State



func enter() -> void:
	super()

func process_input(_event: ) -> State:
	if controls.is_jump_just_pressed():
		return jump_state

	if controls.has_horizontal_input():
		return run_state

	if controls.is_stomp_just_pressed():
		return duck_state
		
	if parent.velocity.y < 0.0:
		return fall_state
	
	return null

func process_physics(delta: float) -> State:
	# need to call move and slide for the non killable bounce to work
	if parent.velocity.y != 0.0:
		parent.move_and_slide()
		
	# fall when not on floor
	if not parent.is_on_floor():
		return  fall_state
	
	# catch player drifting while in idle state
	if abs(parent.velocity.x) > stats.BRAKING_THRESHOLD:
		return brake_state
		
	return null
