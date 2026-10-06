extends PlayerState
class_name FallStatePlayer

@export 
var idle_state: State
@export 
var run_state: State
@export 
var jump_state: State
@export 
var stomp_state: State
@export 
var glide_state: State
@export 
var brake_state: State

func enter() -> void:
	super()

func process_input(_event: InputEvent) -> State:
	
	#jump
	
	if (
	controls.is_jump_just_pressed()
	and move_data.jump_count < stats.MAX_JUMPS
	and move_data.double_jump_buffer_timer <= 0.0
	):
		animation_data.play_double_jump_cloud()
		return jump_state

	#glide when player cant jump anymore and has horizontal input in air
	if (
			stats.GLIDE_ALLOWED
			and controls.has_horizontal_input()
			and move_data.jump_count == stats.MAX_JUMPS
			and move_data.glide_timer <= 0.0
			and not move_data.just_did_glide
			and not parent.is_on_floor()
			):
			return glide_state 

	#stomp
	if controls.is_stomp_just_pressed() and move_data.can_stomp():
		return stomp_state

	return null

func process_physics(delta: float) -> State:
	parent.velocity.y += stats.FALL_GRAVITY * delta

	if move_data.restoring_speed_after_glide:
		parent.velocity.x = move_toward(
			parent.velocity.x,
			move_data.stored_speed_for_glide,
			stats.AIR_ACCELERATION * delta
		)

		if abs(parent.velocity.x - move_data.stored_speed_for_glide) < 5.0:
			move_data.restoring_speed_after_glide = false
	
	else:
			# helper fuction in player_state
			apply_air_movement(delta)

	parent.move_and_slide()
	move_data.update_double_jump_buffer_timer(delta)

	if parent.is_on_floor():
		move_data.reset_jump_data()
		if controls.has_horizontal_input():
			return run_state
		elif not controls.has_horizontal_input() and parent.velocity.x > abs(stats.BRAKING_THRESHOLD):
			return brake_state
		elif not controls.has_horizontal_input() and parent.velocity.x < abs(stats.BRAKING_THRESHOLD):
			return idle_state

		return idle_state

	return null
