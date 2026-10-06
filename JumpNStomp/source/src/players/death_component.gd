## this component handles everything death related.
## it stops the player and sends the death signal.

extends Node
class_name DeathComponent

var sound_machine: SoundMachine
signal died(player: Player, reason: String, killer: Player)

@onready var player := owner as Player
@onready var explosion_particles: GPUParticles2D = player.get_node_or_null("ExplosionParticles")

var stomp_invincible: bool = false

var dead := false


func die(
	reason: String = "unknown",
	killer: Player = null
	) -> void:
	if dead:
		return
	
	# cant die in lobby
	if Global.is_in_lobby:
		return

	# Stomp ignoriert
	if reason == "stomped" and stomp_invincible:
		print("[DEATH COMPONENT:", player.name, "] ignored stomp because duck invincible")
		return

	dead = true
	player.velocity = Vector2.ZERO

	if reason == "stomped":
		_play_death_explosion()
		

	player.set_physics_process(false)
	player.set_process(false)
	player.set_process_unhandled_input(false)
	player.collision_component.set_collision_disabled(true)


	died.emit(player, reason, killer)


func _play_death_explosion() -> void:
	if explosion_particles == null:
		push_warning("ExplosionParticles not found on Player")
		return
	
	sound_machine.play_sound("explosion_player")
		
	explosion_particles.restart()
	explosion_particles.emitting = true


func die_from_ceiling() -> void:
	die("ceiling")


func stomped_by(attacker: Player) -> void:
	# cant die twice
	if dead:
		return
		
	# cant die in lobby
	if Global.is_in_lobby:
		return

	attacker.velocity.y = player.stats.STOMP_BOUNCE_VELOCITY
	die("stomped", attacker)
func set_stomp_invincible(value: bool) -> void:
	# Player.gd setzt diesen Wert abhängig vom Duck-Invincibility-Timer
	stomp_invincible = value
