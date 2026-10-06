extends PlayerState
class_name RunStatePlayer

var footstep_timer := 0.0
var footstep_delay := 0.18

@export var idle_state: State
@export var jump_state: State
@export var fall_state: State
@export var brake_state: State
@export var duck_state: State


func enter() -> void:
	super()
	parent.start_run_particles()
func exit() -> void:
	parent.stop_run_particles()
	
func process_input(_event: InputEvent) -> State:
	
	#jump
	if controls.is_jump_just_pressed():
		return jump_state
	
	# brake when no horizontal kay pressed
	if not controls.has_horizontal_input():
		return brake_state
	
	# floor_slide(for later ;)
	if controls.is_stomp_just_pressed():
		return brake_state

	return null

func process_physics(delta: float) -> State:
	
	# fall when not on floor
	if not parent.is_on_floor():
		return  fall_state
	
	# get direction
	var direction: float = controls.get_x_direction()
	
	# current acceleration from player
	var current_acceleration : float 
	
	# accelerate when on floor
	if parent.is_on_floor():
		current_acceleration = stats.GROUND_ACCELERATION

	if direction != 0.0 and sign(direction) != sign(parent.velocity.x):
		parent.velocity.x = move_toward(
			parent.velocity.x,
			direction * stats.PLAYER_SPEED,
			stats.BRAKING_SPEED * delta
		)
	else:
		parent.velocity.x = move_toward(
			parent.velocity.x,
			direction * stats.PLAYER_SPEED,
			current_acceleration * delta
		)

	
		
	if direction == 0.0:
		return idle_state
		
	parent.update_run_particles_direction()
	parent.move_and_slide()
	
	footstep_timer -= delta

	if parent.is_on_floor() and abs(parent.velocity.x) > 10:
		if footstep_timer <= 0:
			sound_machine.play_sound("footstep")
			footstep_timer = footstep_delay
	return null
	
