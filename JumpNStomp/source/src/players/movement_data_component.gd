extends Node
class_name MovementDataComponent

@onready
var player := owner as Player
@onready 
var stats := $"../PlayerStats" as PlayerStats

# Wie lange der Spieler beim Ducken gegen Stomp geschützt ist
@export var duck_invincibility_duration: float = 1.0

# Wie lange es dauert, bis die Duck-Invincibility wieder verfügbar ist
@export var duck_invincibility_cooldown_length: float = 3.0

# Timer für aktive Invincibility
# > 0 bedeutet: Spieler ist gerade geschützt
var duck_invincibility_timer: float = 0.0

# Cooldown-Timer
# > 0 bedeutet: Fähigkeit ist noch nicht wieder verfügbar
var duck_invincibility_cooldown_timer: float = 0.0

# central counter to keep track of jump and action points.
# no need to change variables on your own. 
# should be only changed and read by other scripts

## important variables basic playermovement 

# jump counter are maxxed out at the int from stats
var jump_count : int = 0

# timer length is changeable in stats
var double_jump_buffer_timer : float = 0.0
var double_jump_buffer_timer_length: float = 0.0

# timer length is changeable in stats
var stomp_cooldown_timer: float = 0.0
var stomp_cooldown_timer_length: float = 1.0

var air_special_used : bool = false

## glide stuff

# we need to know if player just did a glide, so we can get the old x velocity after stop gliding
var just_did_glide : bool = false 

 # for smoother change to old speed
var restoring_speed_after_glide : bool = false

# after glide return to speed berfore glide
var stored_speed_for_glide : float = 0.0 

# timer length is changeable in stats
var glide_timer : float = 0.0
var glide_timer_length : float = 0.0

## ceiling kill stuff

# for button resistance. when hitting ceiling velo is always 0.0, so we need to know how fast we were going
var last_y_velocity: float = 0.0 

## dash stuff
# not implemented

#var last_tap_direction: int = 0
#var double_tap_timer_length: float = 0.0
#var air_dash_buffer_timer : float = 0.0
#var double_tap_window: float = 0.0

## important variables for other player components to keep track of

# store the last facing direction. Important for the turning effect in AnimationComponent 
var last_facing_direction : String = "right" 

# importsnt for wrapper in collision component
var did_wrap : bool =  false

# assign timers on spawning
func _ready() -> void:
	double_jump_buffer_timer_length = stats.DOUBLE_JUMP_BUFFER_TIME
	stomp_cooldown_timer_length = stats.STOMP_COOLDOWN
	glide_timer_length = stats.GLIDE_DURATION_LENGTH
	#double_tap_timer_length = stats.JUMP_TO_DASH_BUFFER
	#double_tap_window = stats.DOUBLE_TAB_WINDOW

# gets generally called when player is ión floor 
func reset_jump_data() -> void:
	jump_count = 0
	double_jump_buffer_timer = 0.0 # buffer to counteract button smashing. duration is changeable in PlayerStats
	air_special_used = false
	glide_timer = 0.0
	just_did_glide = false
	restoring_speed_after_glide = false

func start_double_jump_buffer() -> void: # starts buffer
	double_jump_buffer_timer = double_jump_buffer_timer_length

func update_double_jump_buffer_timer(delta: float) -> void: # counts down buffer
	double_jump_buffer_timer -= delta

func start_stomp_cooldown() -> void:
	stomp_cooldown_timer = stomp_cooldown_timer_length
	
	
func update_stomp_cooldown_timer(delta: float) -> void:
	if stomp_cooldown_timer <= 0.0:
		return

	stomp_cooldown_timer = max(0.0, stomp_cooldown_timer - delta)


func can_stomp() -> bool:
	return stomp_cooldown_timer <= 0.0

func start_glide_timer() -> void: # length for gliding after jump
	glide_timer = glide_timer_length

func update_glide_timer(delta: float) -> void: # update the timer
	glide_timer -= delta

func get_current_velocity_for_storing() -> void:
	stored_speed_for_glide = player.velocity.x

# little helper for letting the player bounce of other player 
# when not enemy in stomp state
func bounce_up() -> void:
	if player == null:
		return
		
	player.velocity.y = stats.NO_STOMP_BOUNCE_VELOCITY
	player.velocity.x = randf_range(
		-stats.NO_KILL_BOUNCE_OFF_RANGE, 
		stats.NO_KILL_BOUNCE_OFF_RANGE
		)
func can_start_duck_invincibility() -> bool:
	# Die Fähigkeit darf nur starten, wenn:
	# 1. gerade keine Invincibility aktiv ist
	# 2. der Cooldown fertig ist
	return duck_invincibility_timer <= 0.0 and duck_invincibility_cooldown_timer <= 0.0


func start_duck_invincibility() -> bool:
	# Wenn Fähigkeit nicht ready ist, passiert nichts
	if not can_start_duck_invincibility():
		return false

	# Invincibility starten
	duck_invincibility_timer = duck_invincibility_duration

	# Gleichzeitig Cooldown starten
	duck_invincibility_cooldown_timer = duck_invincibility_cooldown_length

	print("[MOVE DATA] Duck invincibility started")

	return true


func update_duck_invincibility_timers(delta: float) -> void:
	# Aktive Invincibility runterzählen
	if duck_invincibility_timer > 0.0:
		duck_invincibility_timer -= delta
		duck_invincibility_timer = max(duck_invincibility_timer, 0.0)

	# Cooldown runterzählen
	if duck_invincibility_cooldown_timer > 0.0:
		duck_invincibility_cooldown_timer -= delta
		duck_invincibility_cooldown_timer = max(duck_invincibility_cooldown_timer, 0.0)


func is_duck_invincible() -> bool:
	# True, solange der Invincibility-Timer läuft
	return duck_invincibility_timer > 0.0


func get_duck_invincibility_progress() -> float:
	# Gibt Wert zwischen 0 und 1 zurück
	# 1.0 = Invincibility gerade frisch gestartet
	# 0.0 = Invincibility vorbei
	if duck_invincibility_duration <= 0.0:
		return 0.0

	return duck_invincibility_timer / duck_invincibility_duration
