class_name MyCamera
extends Camera2D

signal activated
signal stoped


var shake_strength: float = 0
var shake_fade: float = 0
var rng := RandomNumberGenerator.new()

@onready var _drag_horizontal_enabled := drag_horizontal_enabled
@onready var _drag_vertical_enabled := drag_vertical_enabled


func _ready() -> void:
	set_process(false)
	GameEvents.screen_shake.connect(_on_screen_shake)
	GameEvents.zoom_changed.emit()

func drag_enabled(_enabled: bool) -> void:
	if _drag_horizontal_enabled:
		drag_horizontal_enabled = _enabled
	if _drag_vertical_enabled:
		drag_vertical_enabled = _enabled

#TODO  use tween.interpolate tocontrol the shake behavior !

func _process(delta: float) -> void:
	if not shake_strength > 15:
		shake_strength = 0
		shake_fade = 0
		offset = Vector2.ZERO
		set_process(false)
		return
	shake_strength = lerpf(shake_strength, 0, delta * shake_fade)
	offset = _get_random_val(shake_strength)


func _on_screen_shake(_strength: float, _fade: float) -> void:
	shake_strength = _strength
	shake_fade = _fade
	set_process(true)


func _get_random_val(val: float) -> Vector2:
	return Vector2(rng.randf_range( -val, val ), rng.randf_range( -val, val ) )

func _on_item_rect_changed() -> void:
	print("camera item rect changed : ok")
