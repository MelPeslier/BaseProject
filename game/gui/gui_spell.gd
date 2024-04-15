class_name GUI_Spell
extends PanelContainer


@export var reload_audio: AudioStreamPlayer
@export var in_time: float = 0.5
@export var out_time: float = 0.25

var progress: float : set = _set_progress
var tween: Tween
var _is_activated := false


func _ready() -> void:
	progress = 0

func show_possible() -> void:
	if _is_activated: return
	_is_activated = true
	reload_audio.play()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "progress", 1.0, in_time)


func hide_possible() -> void:
	if not _is_activated: return
	_is_activated = false
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "progress", 0.0, out_time)


func _set_progress(_progress: float) -> void:
	progress = clampf(_progress, 0, 1)
	material.set_shader_parameter("progress", progress)

