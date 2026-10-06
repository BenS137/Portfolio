extends PlayerState
class_name BrakingStatePlayer

@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var fall_state: State

func enter() -> void:
	super()

func process_input(_event: InputEvent) -> State:
	if controls.is_jump_just_pressed():
		return jump_state

	if controls.has_horizontal_input():
		return run_state
	

	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		return fall_state

	parent.velocity.x = move_toward(
		parent.velocity.x,
		0.0,
		stats.BRAKING_SPEED * delta
	)

	parent.move_and_slide()

	if abs(parent.velocity.x) < stats.BRAKING_THRESHOLD:
		parent.velocity.x = 0.0
		return idle_state

	return null
