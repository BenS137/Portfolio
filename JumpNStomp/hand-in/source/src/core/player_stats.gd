## player movement values in one place for easy testing.
## these are exported so we can tune them in the editor.

extends Node
class_name PlayerStats

## everything horizontal movement
@export_category("Horizontal")

# max horizontal speed on the ground.
@export var PLAYER_SPEED : float = 500.0

# how fast the player reaches max speed on the ground.
@export var GROUND_ACCELERATION : float = 600.0

# how fast the player can change direction in the air.
@export var AIR_ACCELERATION : float = 450.0

# how fast the player slows down when there is no input.
@export var BRAKING_SPEED : float = 2000.0

# threshold for player coming back to idle -> when passed sets velocity to 0
# lower numbers lets player slide more
# should never be too hight, can lead to glitchy movement
@export var BRAKING_THRESHOLD : float = 70.0

# how mach stomp is breaking for later
@export var duck_breaking_factor : float = 2.0




## everything jump
@export_category("Jump")

# how high your max jump velocity is
@export var JUMP_VELOCITY : float = -600.0

# counts all jumps, including the first jump from the floor.
@export var MAX_JUMPS : int = 2

# short lockout after a jump, so button spam does not instantly spend another jump.
@export var DOUBLE_JUMP_BUFFER_TIME : float = 0.1




## everything newton-itious (smaller is stronger)
@export_category("Gravity")

# normal gravity while going up or moving normally.
@export var GRAVITY : float = 700.0

# stronger gravity while falling, for a snappier fall.
@export var FALL_GRAVITY : float = 1000.0




##everything stomp
@export_category("Stomp")

# downward speed when the player stomps.
@export var STOMP_VELOCITY : float = 3200.0

# upward bounce after successfully stomping another player.
@export var STOMP_BOUNCE_VELOCITY : float = -750.0

# upward bounce after successfully stomping another player.
@export var NO_STOMP_BOUNCE_VELOCITY : float = -400.0

# max range of random non killable bounce on x axis
@export var NO_KILL_BOUNCE_OFF_RANGE : float = 0.0

# max range of random killable bounce on x axis
@export var KILL_BOUNCE_OFF_RANGE : float = 600.0



# stomp cooldown
@export var STOMP_COOLDOWN : float = 0.8





## everything glide
@export_category("Glide")

# dont like glide? just deactivate it
@export var GLIDE_ALLOWED : bool = true 

# horizontal speed while gliding.
@export var GLIDE_SPEED : float = 500.0

# how fast player is getting to glide max
@export var GLIDE_ACCELERATION : float = 400.0

# lower gravity while gliding.
@export var GLIDE_GRAVITY : float = 180.0

# how long the glide can last.
@export var GLIDE_DURATION_LENGTH : float = 1.5

# how fast you fall down while in glide
@export var GLIDE_MAX_FALL_SPEED : float = 160.0




## everything animations
@export_category("Animation")

# small delay before the sprite flips direction.
@export var PLAYER_SPRITE_FLIP_DELAY_LENGTH : float = 0.2





## everything blocking (not yet implemented)

# can block attacks
@export var CAN_BLOCK_ATTACKS : bool = true

# duration of block
@export var 	BLOCK_DURATION_LENGTH : float = 2.0

# bounce when attack blocked
@export var BLOCK_BOUNCE_VELOCITY : float = -300.0




## everything airdash (not yet implemented)

# can you airdash
@export var AIR_DASH_ALLOWED : bool = true

# how often can you dash in a given jump
@export var DASH_AMOUNT : int = 1

# buffer between dash`s
@export var DASH_TO_DASH_BUFFER : float = 0.2

# buffer between jump to dash
@export var JUMP_TO_DASH_BUFFER : float = 0.0

# cooldown to counteract spamming 
# remember bigger numbers only possible when using 1 dash per jump
@export var DASH_COOLDOWN : float = 0.1




## other things we wanna change
@export_category("Misc")

# dont like thatyou can kill yourself? just deactivate it
@export var SELF_CEILING_KILL_ALLOWED : bool = true 

# how easily you can kill yourself
@export var PLAYER_BUTTON_RESISTANCE : float = -400.0 
 
# for advanced moves, double tab
@export var DOUBLE_TAB_WINDOW : float = 0.5

# push force for physic bodies
@export var PUSH_FORCE : float = 80.0
