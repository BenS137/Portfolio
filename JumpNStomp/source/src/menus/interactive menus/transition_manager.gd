extends CanvasLayer

@onready var transition_mask: ColorRect = $TransitionMask


func _ready() -> void:
	layer = 100


func transition_to_scene(scene_path: String) -> void:
	transition_mask.transition_to_scene(scene_path)
