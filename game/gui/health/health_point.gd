class_name HealthPoint
extends PanelContainer

@export var heart_beat: AnimatedSprite2D
@export var last_heart_particles: GPUParticles2D
@export var in_time: float = 1.0
@export var out_time: float = 0.75
#@export var gain: AudioStreamPlayer
#@export var lose: AudioStreamPlayer

var progress: float : set = _set_progress
var tween: Tween
#var index: int

func _ready() -> void:
	progress = 0
	last_heart_particles.emitting = false

func lose_health() -> void:
	#lose.play()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "progress", 0.0, out_time)


func gain_health() -> void:
	#gain.play()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "progress", 1.0, in_time)


func last_hp(_is_last: bool) -> void:
	if _is_last:
		heart_beat.play("default")
		last_heart_particles.emitting = true
	else:
		heart_beat.stop()
		last_heart_particles.emitting = false


func _set_progress(_progress: float) -> void:
	progress = clampf(_progress, 0, 1)
	heart_beat.material.set_shader_parameter("progress", progress)
