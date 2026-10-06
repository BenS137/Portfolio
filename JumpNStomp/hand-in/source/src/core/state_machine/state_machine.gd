## this only initiate the state machine for group
## if every state of the player needs the same things please use player_state.gd

extends Node

# universal constants 

@export
var starting_state: State

var current_state: State
var controls: ControlComponent
var stats: PlayerStats
var move_data: MovementDataComponent
var animation_data: AnimationComponent
var collision_component: CollisionComponent
var sound_machine: SoundMachine



#give the children the reference to the state machine

func init(parent: Player) -> void:
	controls = parent.player_controls
	stats = parent.stats
	move_data = parent.move_data
	animation_data = parent.animation_data
	collision_component = parent.collision_component
	sound_machine = parent.sound_machine

	for child in get_children():
		if child is PlayerState:
			child.parent = parent
			child.controls = controls
			child.stats = stats
			child.move_data = move_data
			child.animation_data = animation_data
			child.collision_component = collision_component
			child.sound_machine = sound_machine

	change_state(starting_state)


#change the state by calling exit logic on current state
func change_state(new_state: State) -> void:
	if new_state == null:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()


# Pass through functions for the Player to call
func process_physics(delta: float) -> void:
	if current_state == null:
		return

	var new_state = current_state.process_physics(delta)
	

	collision_component.handle_player_collisions()
	
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	if current_state == null:
		return

	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	if current_state == null:
		return

	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
