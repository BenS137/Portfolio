## a platform with easy to adjust exports 
## also makes duplications of it to make wrapping smooth

@tool
class_name Platform
extends StaticBody2D


var _collision_shape_is_unique := false

# adjustable dials
@export_group("Platform Settings")
@export var platform_size := Vector2(600.0,60.0):
	set(new_size):
		platform_size = new_size
		sync_size_platform()


func _ready() -> void:
	make_collision_shape_unique()
	sync_size_platform() 
	WrapComponent.dup_for_wrap($PlatformCollision, self)
	
func sync_size_platform() -> void:
	if not is_node_ready():
		return
	$PlainPlatformVisual.size = platform_size
	$PlainPlatformVisual.position = -platform_size / 2.0
	make_collision_shape_unique()
	$PlatformCollision.shape.size = platform_size

# we need this for multiple platforms in a level
# because collision_shape_node.shape may be a shared resource
# we need to make sure every platform colission is unique
# so changing one doesnt accidentaly change the collision of the others
func make_collision_shape_unique() -> void:
	if _collision_shape_is_unique:
		return
	if not is_node_ready():
		return

	var collision_shape_node := $PlatformCollision as CollisionShape2D
	var collision_shape := collision_shape_node.shape as Shape2D
	if collision_shape:
		collision_shape_node.shape = collision_shape.duplicate() as Shape2D
		_collision_shape_is_unique = true
