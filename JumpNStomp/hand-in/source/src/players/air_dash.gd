
extends PlayerState
class_name AirDashPlayer

@export
var fall_state: State
@export
var stomp_state: State
@export 
var run_state: State
@export 
var brake_state: State

func enter() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
