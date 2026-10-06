class_name PlayerState
extends State

# Shared settings for all player movement states.
@export var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# References passed in by the StateMachine during init.
var parent: Player
var controls: ControlComponent
var stats: PlayerStats
var move_data: MovementDataComponent
var animation_data: AnimationComponent
var collision_component: CollisionComponent
var sound_machine: SoundMachine


func enter() -> void:

	# see current player state
	print("ENTER STATE: ", name)
	
	# start animation that is declared in state inspector
	parent.player_sprite.play(animation_name)


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	return null


# Reset jump counters after move_and_slide() confirms the player is on the floor.
func reset_jump_data_on_floor() -> void:
	if parent.is_on_floor():
		move_data.reset_jump_data()

# we need this for snappier movement in the air
func apply_air_movement(delta: float) -> void:
	var direction := controls.get_x_direction()
	var target_speed := direction * stats.PLAYER_SPEED
	var acceleration := stats.AIR_ACCELERATION

	if direction != 0.0 and sign(direction) != sign(parent.velocity.x):
		acceleration = stats.BRAKING_SPEED

	parent.velocity.x = move_toward(
		parent.velocity.x,
		target_speed,
		acceleration * delta
	)
