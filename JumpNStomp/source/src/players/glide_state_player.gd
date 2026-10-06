
extends PlayerState
class_name GlideStatePlayer

@export
var fall_state: State
@export
var stomp_state: State
@export 
var run_state: State
@export 
var idle_state: State
@export 
var duck_state: State
@export 
var brake_state: State

func enter() -> void:
	super()
	sound_machine.play_sound("glide")

	# reset the variable every time player glides
	move_data.just_did_glide = false 
	
	# store old x velocity and start timer, so you cant glide endlessly
	move_data.stored_speed_for_glide = parent.velocity.x
	move_data.start_glide_timer()
	
	# cloud animation
	animation_data.start_glide_cloud()
	
	# brings y velocity to the glide velocity
	if parent.velocity.y > stats.GLIDE_MAX_FALL_SPEED:
		parent.velocity.y = stats.GLIDE_MAX_FALL_SPEED

func process_input(_event: InputEvent) -> State:
	
	# when player dont have horizontal input, the player should fall with the old horizontal velocity
	if not controls.has_horizontal_input():
		return end_glide(fall_state)
		
	# when player lets go of the up key
	if controls.is_jump_just_released():
		return end_glide(fall_state)
			
			
	# stomp
	if controls.is_stomp_just_pressed() and move_data.can_stomp():
		return end_glide(stomp_state)
	

	return null

func process_physics(delta: float) -> State:
	# update the glide timer
	move_data.update_glide_timer(delta) 
	
	# loops cloud animation
	animation_data.update_glide_cloud_loop()
	
	# looks if glide timer is 0
	if move_data.glide_timer <= 0.0:
		return end_glide(fall_state)
		

	var direction := controls.get_x_direction()
	var target_speed : float = direction * stats.GLIDE_SPEED

	parent.velocity.x = move_toward(
		parent.velocity.x,
		target_speed,
		stats.GLIDE_ACCELERATION * delta
	)

	parent.velocity.y = move_toward(
		parent.velocity.y,
		stats.GLIDE_MAX_FALL_SPEED,
		stats.GLIDE_GRAVITY * delta
	)

	parent.move_and_slide()

	if parent.is_on_floor():
		animation_data.stop_glide_cloud()
		move_data.reset_jump_data()
		# run
		if controls.has_horizontal_input():
			return run_state
		
		# brake
		elif not controls.has_horizontal_input():
			return brake_state
		# duck
		if not controls.has_horizontal_input() and controls.is_jump_just_pressed():
			return duck_state
	
		return idle_state

	return null

# so we see the full animation before changing state
func end_glide(next_state: State) -> State: 
	move_data.just_did_glide = true
	move_data.restoring_speed_after_glide = true
	animation_data.stop_glide_cloud()
	return next_state # here we give the fall state
	
