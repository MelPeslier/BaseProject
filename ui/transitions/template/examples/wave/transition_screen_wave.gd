extends TransitionScreen

@export var visibility: float : set = _set_visibility
@export var appear_time: float = 1.0
@export var disappear_time: float = 1.0
@export var fill_speed: float = 3.0

var progress_tween: Tween
@onready var bg: ColorRect = $Bg

@onready var mat: ShaderMaterial = bg.material as ShaderMaterial

func _ready() -> void:
	super()
	actual_progress = 0.0
	visibility = 0.0

func _appear() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "visibility", 1.0, appear_time)
	tween.tween_callback(_post_appeared)

func _disappear() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "visibility", 0.0, disappear_time)
	tween.tween_callback(_post_disappeared)


func _set_progress(_progress: float) -> void:
	super(_progress)
	if not has_appeared : return
	print("progress : ", progress)
	# Trying to make the fill speed stay related to the fill speed choosed
	var fill_coef := remap(progress - actual_progress, 0.0, 1.0, 0.1, fill_speed)

	if progress_tween and progress_tween.is_running():
		progress_tween.kill()
	progress_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	progress_tween.tween_property(self, "actual_progress", progress, fill_coef)

func _set_actual_progress(_actual_progress: float) -> void:
	super(_actual_progress)
	print(" actual_progress : ",actual_progress)
	mat.set_shader_parameter("progress", actual_progress)

func _set_visibility( _visibility: float ) -> void:
	visibility = clampf(_visibility, 0.0, 1.0)
	mat.set_shader_parameter("visibility", visibility)
