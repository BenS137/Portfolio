extends CharacterBody2D
class_name Player

# the player script act as a connection/ hub for all the components, states, 
# collision, sensors, and nodes with constants like player stats.
# it should be only used things that needs to be monitored in avery state of the player,
# for example: looking if you where stomped. but try to maybe try to make it a state first. 
# I made the stomped function only as a last resort in this script and maybe gonna out it in a stomped state
# if I got time.

# the way code flows in the player body is Player -> PlayerSats (for constants like speed, jump height, etc),
# -> Statemachine(for movement) -> State

# if player gets stomped or dies, the deathcomponent takes over. 

# things to keep track of for movement is in the movement data component (atm only jump counter for max jumps)


@onready
var player_sprite := $PlayerVisual as AnimatedSprite2D
@onready
var sound_machine := $Components/SoundMachine
@onready
var stats := $Components/PlayerStats
@onready 
var score_board := "res://src/worlds/objects/score_board.tscn"
@onready 
var death_component := $Components/DeathComponent
@onready 
var player_controls := $Components/ControlComponent
@onready
var state_machine := $StateMachine
@onready
var move_data := $Components/MovementDataComponent
@onready 
var animation_data := $Components/AnimationComponent
@onready
var collision_component := $Components/CollisionComponent
#particles
@onready var run_particles: GPUParticles2D = $RunParticles
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles
@onready var player_visual: Node2D = $PlayerVisual


const P1_MARKER := preload("res://hand-in/source/src/assets/player_sprites/marker/P1_Marker.png")
const P2_MARKER := preload("res://hand-in/source/src/assets/player_sprites/marker/P2_Marker.png")

@onready var player_marker: Sprite2D = $PlayerMarker
const STOMP_COOLDOWN_SHADER := preload("res://hand-in/source/src/vfx/effects/shader/stomp_cooldown_shader.gdshader")

var stomp_shader_material: ShaderMaterial

# Wie lange der grüne Ready-Flash sichtbar sein soll
@export var duck_ready_flash_duration: float = 0.4

# Interner Timer für den grünen Flash
var duck_ready_flash_timer: float = 0.0
# standart is player 1
@export var player_number := 1

# redirect input to state machines _ready
# also handles things like: 
# animation, wrap copies, assigningthe player control layout
# use super() in ready of the given state 

func _ready() -> void:
	var player_number := _get_player_number()

	player_controls.set_player_number(player_number)
	
	death_component.sound_machine = sound_machine
	
	run_particles.process_material = run_particles.process_material.duplicate()
	run_particles.emitting = false

	_apply_player_marker(player_number)

	_apply_selected_character()
	
	_setup_stomp_shader()

	WrapComponent.dup_for_wrap($PlayerVisual, self)
	WrapComponent.dup_for_wrap($PlayerCollisionMainBody, self)
	WrapComponent.dup_for_wrap($PlayerMarker, self)

	state_machine.init(self)
	
#marker matcher
func _apply_player_marker(player_number: int) -> void:
	match player_number:
		1:
			player_marker.texture = P1_MARKER
		2:
			player_marker.texture = P2_MARKER


# redirect input to state machines process_input
func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

# state machines own _physics_process
# state machines own _physics_process
func _physics_process(delta: float) -> void:
	animation_data.handle_flip(delta, velocity.x)

	# Stomp-Cooldown runterzählen
	move_data.update_stomp_cooldown_timer(delta)

	# Duck-Cooldown vor dem Update merken,
	# damit wir erkennen, wann er gerade fertig geworden ist
	var duck_cooldown_before: float = move_data.duck_invincibility_cooldown_timer

	# Duck-Invincibility und Cooldown runterzählen
	move_data.update_duck_invincibility_timers(delta)

	# Wenn der Duck-Cooldown gerade von aktiv auf fertig wechselt,
	# starten wir einmal den grünen Ready-Flash
	if duck_cooldown_before > 0.0 and move_data.duck_invincibility_cooldown_timer <= 0.0:
		_start_duck_ready_flash()

	# Shader aktualisieren
	_update_stomp_cooldown_shader()
	_update_duck_invincibility()
	_update_duck_ready_flash(delta)

	# State Machine und Screen Wrap
	state_machine.process_physics(delta)
	collision_component.handle_screen_wrap()
	animation_data.handle_flip(delta, velocity.x)


# state machines own _process
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	#animation_data.update_stomp_cooldown_bar()

# Who Stomped Ya (biggie homage if you know you know)
# we need to look if player is/was stomped in here, and by whom/what
func get_stomped_by(attacker: Player) -> void: 
	
	if death_component.dead:
		return
		
	if Global.is_in_lobby:
		return
		
	attacker.velocity.y = stats.STOMP_BOUNCE_VELOCITY
	death_component.die("stomped", attacker)

# every player has its own number
# we want to know what sprite we nee to copy for the wrap
# and to keep the same sprite after queue_free
func _get_player_number() -> int:


	if player_number == 2 or name.ends_with("2"):
		return 2

	return 1

# applies sprite to player number
# flow is from player sellect screen assigns number -> global is saving it
# and here we apply it chosing the roght sprite
func _apply_selected_character() -> void:
	# player 1 is defaulr
	var selected_character := Global.player1_character

	# assigns player 2
	if _get_player_number() == 2:
		selected_character = Global.player2_character
	
	# 
	player_sprite.sprite_frames = PlayerCharacterLibrary.create_sprite_frames(
		player_sprite.sprite_frames, 
		selected_character
		)
		
	player_sprite.play("Idle")
	

	#player_sprite.sprite_frames = PlayerCharacterLibrary.create_sprite_frames(
		#player_sprite.sprite_frames, 
		#selected_character)
	#
	#player_sprite.play("Idle")
func start_run_particles() -> void:
	run_particles.emitting = true


func stop_run_particles() -> void:
	run_particles.emitting = false


func update_run_particles_direction() -> void:
	var mat := run_particles.process_material as ParticleProcessMaterial
	if mat == null:
		return

	if velocity.x > 0:
		# Player läuft nach rechts, Staub fliegt nach links
		mat.direction = Vector3(-1, -0.3, 0)
	elif velocity.x < 0:
		# Player läuft nach links, Staub fliegt nach rechts
		mat.direction = Vector3(1, -0.3, 0)
func play_death_explosion() -> void:
	explosion_particles.restart()
	explosion_particles.emitting = true
	
func set_stomp_cooldown_shader(progress: float) -> void:
	if stomp_shader_material == null:
		return

	progress = clamp(progress, 0.0, 1.0)
	stomp_shader_material.set_shader_parameter("cooldown_progress", progress)
	if stomp_shader_material == null:
		return

	progress = clamp(progress, 0.0, 1.0)
	
	
	stomp_shader_material.set_shader_parameter("cooldown_progress", progress)
	if stomp_shader_material == null:
		return

	progress = clamp(progress, 0.0, 1.0)
	stomp_shader_material.set_shader_parameter("cooldown_progress", progress)

	progress = clamp(progress, 0.0, move_data.stomp_cooldown_timer_length)
	player_visual.material.set_shader_parameter("cooldown_progress", progress)
	
func _setup_stomp_shader() -> void:
	# Neues ShaderMaterial erstellen
	stomp_shader_material = ShaderMaterial.new()

	# Shader-Datei zuweisen
	stomp_shader_material.shader = STOMP_COOLDOWN_SHADER

	# Wichtig:
	# PlayerVisual darf nicht das Parent-Material benutzen,
	# sonst wird unser Shader ignoriert.
	player_sprite.use_parent_material = false

	# ShaderMaterial auf den sichtbaren Sprite setzen
	player_sprite.material = stomp_shader_material

	# Alle Shader-Werte am Anfang ausschalten
	set_stomp_cooldown_shader(0.0)
	set_duck_invincibility_shader(0.0)
	set_duck_invincibility_ready_shader(0.0)
	
func _update_stomp_cooldown_shader() -> void:
	if move_data.stomp_cooldown_timer_length <= 0.0:
		set_stomp_cooldown_shader(0.0)
		return

	var progress : float= move_data.stomp_cooldown_timer / move_data.stomp_cooldown_timer_length

	set_stomp_cooldown_shader(progress)
func try_start_duck_invincibility() -> void:
	# Wird vom DuckState aufgerufen, wenn der Spieler ducked

	if move_data.start_duck_invincibility():
		# Sound für Duck/Invisibility
		sound_machine.play_sound("invisible_effect")
		# Wenn die Fähigkeit ready war:
		# DeathComponent schützt jetzt gegen Stomp
		death_component.set_stomp_invincible(true)

		# Shader direkt voll aktiv setzen
		set_duck_invincibility_shader(1.0)

		print("[PLAYER:", name, "] Duck invincibility activated")
	else:
		# Duck funktioniert trotzdem, aber ohne Invincibility
		print("[PLAYER:", name, "] Duck invincibility on cooldown")


func _update_duck_invincibility() -> void:
	# Prüfen, ob der Spieler gerade durch Duck geschützt ist
	var is_invincible: bool = move_data.is_duck_invincible()

	# DeathComponent bekommt den aktuellen Schutzstatus
	death_component.set_stomp_invincible(is_invincible)

	# Goldener Shader während aktiver Invincibility
	var duck_invincible_progress: float = move_data.get_duck_invincibility_progress()
	set_duck_invincibility_shader(duck_invincible_progress)


func set_duck_invincibility_shader(progress: float) -> void:
	# Setzt den goldenen Shader-Effekt während aktiver Invincibility

	if stomp_shader_material == null:
		return

	progress = clamp(progress, 0.0, 1.0)
	stomp_shader_material.set_shader_parameter("duck_invincible_progress", progress)


func set_duck_invincibility_ready_shader(progress: float) -> void:
	# Setzt den grünen Shader-Effekt, wenn Duck-Invincibility ready ist

	if stomp_shader_material == null:
		return

	progress = clamp(progress, 0.0, 1.0)
	stomp_shader_material.set_shader_parameter("duck_invincible_ready", progress)
func _start_duck_ready_flash() -> void:
	# Startet einen kurzen grünen Flash,
	# wenn die Duck-Invincibility wieder verfügbar ist.
	duck_ready_flash_timer = duck_ready_flash_duration
	print("[PLAYER:", name, "] Duck invincibility recharged")


func _update_duck_ready_flash(delta: float) -> void:
	# Wenn kein Flash läuft, Shader ausmachen
	if duck_ready_flash_timer <= 0.0:
		set_duck_invincibility_ready_shader(0.0)
		return

	# Flash-Timer runterzählen
	duck_ready_flash_timer -= delta
	duck_ready_flash_timer = max(duck_ready_flash_timer, 0.0)

	# Progress geht von 1.0 zu 0.0
	var progress: float = duck_ready_flash_timer / duck_ready_flash_duration

	set_duck_invincibility_ready_shader(progress)
