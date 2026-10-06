# =============================================================================
# 
# Script written by Roadside Games
# 
# This script is completely free to use, modify, and distribute.
# No attribution required, though it's always appreciated!
#  https://github.com/roadside-games/godot-guides/tree/master/guide_transition_texture_mask
# =============================================================================
extends ColorRect

# ===================================================
# VARIABLES
# ===================================================
@export_category("Zoom Settings")
@export var zoom_start: float = 2.0
@export var zoom_end: float = 0.0
@export var zoom_tween_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var zoom_ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_category("Center Settings")
@export var center_start: Vector2 = Vector2(0.5, 0.3)
@export var center_end: Vector2 = Vector2(0.5, 0.5)
@export var center_tween_type: Tween.TransitionType = Tween.TransitionType.TRANS_BOUNCE
@export var center_ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_category("Strength Settings")
@export var strength_start: float = 0.4
@export var strength_end: float = 0.0
@export var strength_tween_type: Tween.TransitionType = Tween.TransitionType.TRANS_EXPO
@export var strength_ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_category("Duration Settings")
@export var duration_in: float = 1.6
@export var duration_out: float = 1.6
@export var await_time: float = 1.0

var _tween: Tween

# ===================================================
# INITIALIZATION
# ===================================================
func _ready() -> void:
	size = get_viewport_rect().size
	z_index = 1000
	mouse_filter = MOUSE_FILTER_IGNORE

	# Shader im Menü nicht sichtbar
	visible = false

	# Startwerte vorbereiten aber noch nicht anzeigen
	_set_shader_values(strength_start, zoom_start, center_start)

# ===================================================
# TWEENING IN AND OUT
# ===================================================
## Start the tweening in for the texture mask
func fade_in() -> void:
	_set_shader_values(strength_start, zoom_start, center_start)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.parallel().tween_method(_shader_value_progress, strength_start, strength_end, duration_in).set_trans(strength_tween_type).set_ease(strength_ease_type)
	_tween.parallel().tween_method(_shader_value_zoom, zoom_start, zoom_end, duration_in).set_trans(zoom_tween_type).set_ease(zoom_ease_type)
	_tween.parallel().tween_method(_shader_value_center, center_start, center_end, duration_in).set_trans(center_tween_type).set_ease(center_ease_type)
	_tween.tween_callback(fade_out)
	_tween.play()

## Start the tweening out for the texture mask
func fade_out() -> void:
	await get_tree().create_timer(await_time).timeout
	_set_shader_values(strength_end, zoom_end, center_end)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.parallel().tween_method(_shader_value_progress, strength_end, strength_start, duration_out).set_trans(strength_tween_type).set_ease(strength_ease_type)
	_tween.parallel().tween_method(_shader_value_zoom, zoom_end, zoom_start, duration_out).set_trans(zoom_tween_type).set_ease(zoom_ease_type)
	_tween.parallel().tween_method(_shader_value_center, center_end, center_start, duration_out).set_trans(center_tween_type).set_ease(center_ease_type)
	_tween.play()

# ===================================================
# SET SHADER VALUES
# ===================================================
## Set the shader values for the texture mask shader parameters
func _set_shader_values(strength_value: float, zoom_value: float, center_value: Vector2) -> void:
	material.set_shader_parameter("strength", strength_value)
	material.set_shader_parameter("zoom", zoom_value)
	material.set_shader_parameter("center", center_value)

## Set the strength shader parameter value for tween method
func _shader_value_progress(value: float) -> void:
	material.set_shader_parameter("strength", value)

## Set the zoom shader parameter value for tween method
func _shader_value_zoom(value: float) -> void:
	material.set_shader_parameter("zoom", value)

## Set the center shader parameter value for tween method
func _shader_value_center(value: Vector2) -> void:
	material.set_shader_parameter("center", value)
	
func transition_to_scene(scene_path: String) -> void:
	# Falls gerade ein Tween läuft, abbrechen
	if _tween:
		_tween.kill()

	# Startwerte setzen, bevor die Transition sichtbar wird
	# Dadurch sieht man keinen alten Shader-Zustand für 1 Frame
	_set_shader_values(strength_start, zoom_start, center_start)

	# Transition sichtbar machen
	visible = true

	# Erste Hälfte: Maske geht rein / Bildschirm wird verdeckt
	_tween = create_tween()

	_tween.parallel().tween_method(
		_shader_value_progress,
		strength_start,
		strength_end,
		duration_in
	).set_trans(strength_tween_type).set_ease(strength_ease_type)

	_tween.parallel().tween_method(
		_shader_value_zoom,
		zoom_start,
		zoom_end,
		duration_in
	).set_trans(zoom_tween_type).set_ease(zoom_ease_type)

	_tween.parallel().tween_method(
		_shader_value_center,
		center_start,
		center_end,
		duration_in
	).set_trans(center_tween_type).set_ease(center_ease_type)

	await _tween.finished

	# Ganz wichtig:
	# Vor dem Scene-Wechsel nochmal sicherstellen,
	# dass der Bildschirm wirklich komplett verdeckt ist.
	_set_shader_values(strength_end, zoom_end, center_end)

	# Scene wechseln, während alles verdeckt ist
	get_tree().change_scene_to_file(scene_path)

	# Neue Scene kurz laden/layouten lassen.
	# Das verhindert den "Sprung" in der Mitte.
	await get_tree().process_frame
	await get_tree().process_frame

	# Kleiner Hold, damit der Wechsel nicht hektisch wirkt
	await get_tree().create_timer(0.08).timeout

	# Nach dem Laden nochmal Endwerte setzen,
	# damit kein Zwischenzustand sichtbar wird
	_set_shader_values(strength_end, zoom_end, center_end)

	# Zweite Hälfte: Maske geht wieder raus
	_tween = create_tween()

	_tween.parallel().tween_method(
		_shader_value_progress,
		strength_end,
		strength_start,
		duration_out
	).set_trans(strength_tween_type).set_ease(strength_ease_type)

	_tween.parallel().tween_method(
		_shader_value_zoom,
		zoom_end,
		zoom_start,
		duration_out
	).set_trans(zoom_tween_type).set_ease(zoom_ease_type)

	_tween.parallel().tween_method(
		_shader_value_center,
		center_end,
		center_start,
		duration_out
	).set_trans(center_tween_type).set_ease(center_ease_type)

	await _tween.finished

	# Nach der Transition komplett ausblenden
	visible = false
