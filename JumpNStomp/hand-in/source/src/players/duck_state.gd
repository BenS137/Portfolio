extends PlayerState
class_name DuckStatePlayer

@export var idle_state: State
@export var run_state: State
@export var jump_state: State
@export var fall_state: State

func enter() -> void:
	super()

	print("[DUCK STATE] ENTER")

	# Beim Ducken tehen bleiben
	parent.velocity.x = 0.0

	# Lauf-Partikel ausschalten
	parent.stop_run_particles()

	# Versucht die Duck-Invincibility zu starten.
	# Wenn sie auf Cooldown ist, passiert nichts.
	parent.try_start_duck_invincibility()

func process_input(_event: InputEvent) -> State:
	if controls.is_jump_just_pressed():
		return jump_state

	if controls.has_horizontal_input():
		return run_state

	if not controls.is_stomp_pressed():
		return idle_state

	return null

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	if not parent.is_on_floor():
		return fall_state

	return null
