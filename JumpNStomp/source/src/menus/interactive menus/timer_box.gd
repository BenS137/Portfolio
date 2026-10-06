extends RigidBody2D
class_name TimerBox

# get the lobby variables
@onready
var lobby := get_parent().get_parent() as Lobby

# get thee label
@onready
var timer_label := $TimerLabel as RichTextLabel

# togggle
var activated : bool = false
var sound_machine: SoundMachine

func _ready() -> void:
	# clear old text
		timer_label.clear()
		
		
		# we have the default showing
		#timer_label.text = "NO MATCH TIMER"
		update_label()
		
		
		

func update_label() -> void:
	
	# we set timer = the lobby variable
	if lobby.timer_minutes == 0:
		timer_label.text = "NO MATCH TIMER"
		lobby.timer_enabled = false
		
		return
		

	if lobby.timer_minutes == 1:
		timer_label.text = (str(lobby.timer_minutes) + "\n" + "MINUTE")
		lobby.timer_enabled = true
		
		return
	
	if lobby.timer_minutes in range(2,6):
		timer_label.text = (str(lobby.timer_minutes) + "\n" + "MINUTES")
		lobby.timer_enabled = true
		return


# plays when player is stomping the box,  if he isnt, just stand on it
func timer_stomped(player: Player) -> void:
	# toggle on
	activated = true
	
	# ignore other states when inter acting with it
	if player.state_machine.current_state is not StompStatePlayer:
		return

	
	# check if player is in stomp state and box has no life
	if (player.state_machine.current_state is StompStatePlayer 
	):
		sound_machine = player.sound_machine

		if sound_machine:
			sound_machine.play_sound("select")
		
		lobby.timer_minutes = wrapi(lobby.timer_minutes + 1, 0, 6)
		update_label()

	
		# bounce up when stomping
	
		player.velocity.y = player.stats.NO_STOMP_BOUNCE_VELOCITY
		player.velocity.x = randf_range(
		-player.stats.NO_KILL_BOUNCE_OFF_RANGE,
		player.stats.NO_KILL_BOUNCE_OFF_RANGE
			)
		activated = false
			
	
