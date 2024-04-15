extends Node

signal transition_finished

@onready var camera2D := MyCamera.new()
var following_this : Node2D

var tween: Tween

#region interpolation
var to_cam: MyCamera
var initial_value: Vector2
var elapsed_time: float
var duration: float
var trans_type := Tween.TRANS_CUBIC
var ease_type := Tween.EASE_IN_OUT
#endregion


func _ready() -> void:
	camera2D.enabled = false
	add_child(camera2D)
	set_process(false)


func _process(delta: float) -> void:
	elapsed_time += delta
	var delta_value := to_cam.global_position - initial_value
	camera2D.global_position = Tween.interpolate_value(initial_value, delta_value, elapsed_time, duration, trans_type, ease_type)


func set_interp_params(_to: MyCamera, _initial_value: Vector2, _duration: float, _trans_type := Tween.TRANS_CUBIC, _ease_type := Tween.EASE_IN_OUT) -> void:
	to_cam = _to
	initial_value = _initial_value
	elapsed_time = 0
	duration = _duration
	trans_type = _trans_type
	ease_type = _ease_type


func switch_camera2D(from: Camera2D, to: Camera2D) -> void:
	to.enabled = true
	to.make_current()
	from.enabled = false


func transition_camera2D(_from: MyCamera, _to: MyCamera, _duration: float = 1.0, _trans := Tween.TRANS_CUBIC, _ease := Tween.EASE_IN_OUT) -> void:
	if not _from:
		_from = get_viewport().get_camera_2d()
	if not _from:
		push_error("no active camera")
		return
	var is_ok := true
	if tween and tween.is_running():
		set_process(false)
		is_ok = false
		_from = camera2D

	# Déplacer la caméra depuis celle actuelle vers la nouvelle
	camera2D.zoom = _from.zoom
	camera2D.offset = _from.offset
	camera2D.light_mask = _from.light_mask
	camera2D.global_transform = _from.global_transform
	#camera2D.global_position = from.get_screen_center_position()
	camera2D.global_position = _from.get_target_position()

	# Make our transition camera current
	camera2D.enabled = true
	camera2D.make_current()
	if is_ok:
		_from.enabled = false
	_to.drag_enabled(false)

	#region interpolation
	set_interp_params(_to, camera2D.global_position, _duration, _trans, _ease)
	set_process(true)
	#endregion

	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()

	tween.tween_property(camera2D, "global_rotation", _to.global_rotation, _duration)\
	.set_trans(_trans).set_ease(_ease)
	tween.parallel().tween_property(camera2D, "global_skew", _to.global_skew, _duration)\
	.set_trans(_trans).set_ease(_ease)
	tween.parallel().tween_property(camera2D, "global_scale", _to.global_scale, _duration)\
	.set_trans(_trans).set_ease(_ease)
	tween.parallel().tween_property(camera2D, "zoom", _to.zoom, _duration)\
	.set_trans(_trans).set_ease(_ease)
	tween.parallel().tween_property(camera2D, "offset", _to.offset, _duration)\
	.set_trans(_trans).set_ease(_ease)

	# Make the second camera current

	tween.tween_property(_to, "enabled", true, 0)
	tween.tween_callback(_to.make_current)
	tween.tween_callback(set_process.bind(false))
	tween.tween_property(camera2D, "enabled", false, 0)
	tween.tween_callback(_to.drag_enabled.bind(true))
	tween.tween_callback(camera_swiched)


func camera_swiched() -> void:
	transition_finished.emit()
