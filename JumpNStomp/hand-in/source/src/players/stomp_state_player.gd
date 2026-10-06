extends PlayerState
class_name StompStatePlayer

@export var idle_state: State
@export var run_state: State
@export var brake_state: State


func enter() -> void:
	super()
	sound_machine.play_sound("stomp")
	move_data.start_stomp_cooldown()
	parent.set_stomp_cooldown_shader(1.0)
	parent.velocity.y = stats.STOMP_VELOCITY

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.velocity.x = controls.get_x_direction() * stats.PLAYER_SPEED
	parent.move_and_slide()

	if parent.is_on_floor():
		if controls.has_horizontal_input():
			return run_state
		
		elif not controls.has_horizontal_input():
			return brake_state
		
		else: return brake_state

	 

		return idle_state
		
	

	return null
