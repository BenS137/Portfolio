extends PlayerState
class_name JumpState

@export 
var idle_state: State
@export 
var run_state: State
@export 
var stomp_state: State
@export
var fall_state: State
@export
var jump_state: State
@export
var glide_state: State

func enter() -> void:
	super()
	sound_machine.play_sound("jump")
	move_data.start_double_jump_buffer()
	parent.velocity.y = stats.JUMP_VELOCITY
	move_data.jump_count += 1
	

func process_input(_event: InputEvent) -> State:
	#jump
	if (
		controls.is_jump_just_pressed()
	and move_data.jump_count < stats.MAX_JUMPS
	and move_data.double_jump_buffer_timer <= 0
	):
		animation_data.play_double_jump_cloud()
		return jump_state
	
	#fall
	if controls.is_jump_just_released() and parent.velocity.y < 0:
		parent.velocity.y = stats.JUMP_VELOCITY / 4.0
		return fall_state
		
	#stomp
	if controls.is_stomp_just_pressed() and move_data.can_stomp():
		return stomp_state
	
	#glide
	if (
		controls.has_horizontal_input()
		and move_data.jump_count <= 0
		and move_data.glide_timer <= 0.0
		and not parent.is_on_floor()
		):
		return glide_state
	return fall_state



func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	
	# helper fuction in player_state
	apply_air_movement(delta)

	move_data.last_y_velocity = parent.velocity.y
	parent.move_and_slide()
	move_data.update_double_jump_buffer_timer(delta)
	if parent.is_on_floor():
		parent.move_data.reset_jump_data()
		if controls.has_horizontal_input():
			return run_state

		return idle_state

	return null
