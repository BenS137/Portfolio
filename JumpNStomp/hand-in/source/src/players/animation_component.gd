## handles player animation data like sprite flipping and death animation.
## handles also various vfx

extends Node
class_name AnimationComponent

""""""

@onready 
var player := owner as Player
@onready 
var sprite := player.get_node("PlayerVisual") as AnimatedSprite2D
@onready
var player_vfx := $"../../PlayerVfx" as AnimatedSprite2D
@onready 
var move_data := $"../MovementDataComponent"
@onready 
var stats := $"../PlayerStats"


# variables
""""""

# visual delay after changing directions a la paper mario
var sprite_flip_delay_length: float = 0.0
var flip_delay_timer: float = 0.0
var sprite_flipped: bool = false
var sprite_direction: String = "right"
var wanted_sprite_flipped: bool = false

# we need this because some vfx animation are playing when changing state
# otherwise the animation would cancel half way (for examole the glide cloud fading)
var player_vfx_cloud_fade: bool = false

# functions
""""""

# hides the vfx layer on starting
func _ready() -> void:
	sprite_flip_delay_length = stats.PLAYER_SPRITE_FLIP_DELAY_LENGTH

	if player_vfx == null:
		return

	player_vfx.visible = false



# start timer
func start_player_sprite_flip_timer() -> void:
	flip_delay_timer = sprite_flip_delay_length

#update timer
func update_Sprite_flip_timer(delta: float) -> void:
	flip_delay_timer -= delta

# change flip bool
func change_sprite_flip(velocity: float) -> bool:
	if velocity < 0.0:
		return true
	elif velocity > 0.0:
		return false

	return sprite_flipped

# direction for flip
func update_sprite_flip_direction(flipped: bool) -> String:
	if flipped:
		sprite_direction = "left"
	else:
		sprite_direction = "right"

	return sprite_direction

# visual update 
func update_flip(_velocity: float, direction: String) -> void:
	sprite_direction = direction
	sprite.flip_h = sprite_flipped

	if sprite_direction == "left":
		sprite.offset.x = -2
	else:
		sprite.offset.x = 0

# the core of the sprite flip
func handle_flip(delta: float, velocity: float) -> void:
	var new_sprite_flipped := change_sprite_flip(velocity)

	if new_sprite_flipped != sprite_flipped and new_sprite_flipped != wanted_sprite_flipped:
		wanted_sprite_flipped = new_sprite_flipped
		start_player_sprite_flip_timer()

	if flip_delay_timer > 0.0:
		update_Sprite_flip_timer(delta)
		return

	if wanted_sprite_flipped != sprite_flipped:
		sprite_flipped = wanted_sprite_flipped
		var direction := update_sprite_flip_direction(sprite_flipped)
		update_flip(velocity, direction)

# handle death animation
func play_death_and_wait() -> void:
	if sprite.sprite_frames == null:
		return

	if not sprite.sprite_frames.has_animation("Die"):
		return

	sprite.visible = true
	sprite.frame = 0
	sprite.play("Die")

	await sprite.animation_finished

# start the glide cloud
func start_glide_cloud() -> void:
	if player_vfx == null:
		return

	player_vfx_cloud_fade = false
	player_vfx.visible = true
	player_vfx.play("Cloud_Start")

# loop the glide cloud after the start animation
func update_glide_cloud_loop() -> void:
	if player_vfx == null:
		return

	if player_vfx.animation == "Cloud_Start" and not player_vfx.is_playing():
		player_vfx.play("Cloud_Main_Animation")

# handle the glide end animation
func stop_glide_cloud() -> void:
	# no cloud - no animation
	if player_vfx == null or player_vfx_cloud_fade:
		return 

	# play animation and make the cloud invisible
	player_vfx_cloud_fade = true
	player_vfx.visible = true
	player_vfx.play("Cloud_Fade")

	await player_vfx.animation_finished

	if player_vfx != null and player_vfx.animation == "Cloud_Fade":
		player_vfx.visible = false

	player_vfx_cloud_fade = false


# animate air jump
func play_double_jump_cloud() -> void:
	player_vfx.visible = true
	player_vfx.frame = 0
	player_vfx.play("air_jump")
	await player_vfx.animation_finished
	player_vfx.visible = false
