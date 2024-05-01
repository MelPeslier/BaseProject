class_name TransitionScreen
extends Control

signal appeared
signal disappeared
signal progress_filled
signal change_scene_available

var actual_progress : float = 0.0 : set = _set_actual_progress
var progress: float = 0 : set = _set_progress

var has_appeared := false : set = _set_has_appeared
var loading_screen_finished := false

func _ready() -> void:
	progress = 0.0
	visible = false

#region To Re-Write
func _appear() -> void:
	# Animation here
	# Then call this method signal
	_post_appeared()

func _disappear() -> void:
	# Animation here
	# Then call this method signal
	_post_disappeared()
#endregion

func _post_disappeared() -> void:
	visible = false
	disappeared.emit()
	queue_free()


func _post_appeared() -> void:
	has_appeared = true
	progress = progress
	appeared.emit()


func appear() -> void:
	visible = true
	GameState.in_cinematic = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_appear()

func disappear() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.in_cinematic = false
	_disappear()


func _set_has_appeared(_has_appeared: bool) -> void:
	has_appeared = _has_appeared


func _set_progress(_progress: float) -> void:
	progress = clampf( _progress, 0.0, 1.0 )

func _set_actual_progress(_actual_progress: float) -> void:
	if _actual_progress == 1.0 and actual_progress != 1.0:
		change_scene_available.emit()
		progress_filled.emit()
	actual_progress = clampf(_actual_progress, 0.0, 1.0)


