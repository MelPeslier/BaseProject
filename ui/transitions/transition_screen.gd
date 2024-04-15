class_name TransitionScreen
extends CanvasLayer

@export var root_node: Control
@onready var color_rect: ColorRect = $RootNode/ColorRect

var tween: Tween
var max_time : float = 1
var tween_time: float = 0 : set = _set_tween_time
var progress: float = 0 : set = _set_progress

func _ready() -> void:
	visible = false


func appear(_time: float) -> void:
	max_time = _time
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween_time = 0
	tween.tween_property(self, "visible", true, 0.01)
	tween.tween_method(_set_tween_time, tween_time, _time, _time)


func disappear(_time: float) -> void:
	max_time = _time
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()

	tween.tween_method(_set_tween_time, tween_time, 0, _time)
	tween.tween_property(self, "visible", false, 0.01)


func _set_tween_time(_time: float) -> void:
	tween_time = _time
	progress = remap(tween_time, 0, max_time, 0, 1)


func _set_progress(_progress: float) -> void:
	progress = clampf( _progress, 0, 1 )
	if color_rect.material:
		color_rect.material.set_shader_parameter("progress", progress)
