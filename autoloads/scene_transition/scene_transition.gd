extends CanvasLayer

@export var animator: AnimationPlayer
@export var bg: ColorRect


@export var visibility: float : set = _set_visibility
var _scene_path: String = ""
var progress: float: set = _set_progress
var progress_tween: Tween
@export var fill_speed: float = 2


@onready var control_root: Control = $ControlRoot

func _ready() -> void:
	set_process(false)
	visible = false


func reload_current_scene() -> void:
	appear()
	await animator.animation_finished

	if progress_tween and progress_tween.is_running():
		progress_tween.kill()
	progress_tween = create_tween()
	progress_tween.tween_property(self, "progress", 1, fill_speed)
	progress_tween.tween_callback( get_tree().reload_current_scene )
	progress_tween.tween_interval( 0.15 )
	progress_tween.tween_callback( disappear )



func change_scene(_target_path: String) -> void:
	appear()
	_scene_path = _target_path
	ResourceLoader.load_threaded_request( _target_path )
	set_process(true)


func _process(_delta: float) -> void:
	var status = get_status()
	if progress_tween and progress_tween.is_running():
		progress_tween.kill()
	progress_tween = create_tween()
	progress_tween.tween_property(self, "progress", max(get_progress(), 0.33), fill_speed)

	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			disappear()

		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			if animator.is_playing():
				await animator.animation_finished
			if progress_tween and progress_tween.is_running():
				progress_tween.kill()
			progress_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			progress_tween.tween_property(self, "progress", 1.0, fill_speed - progress)
			progress_tween.tween_callback( change_scene_to_resource )
			progress_tween.tween_interval( 0.3 )
			progress_tween.tween_callback( disappear )


func get_status() -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status( _scene_path )


func get_progress() -> ResourceLoader.ThreadLoadStatus:
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(_scene_path, progress_array)
	return progress_array.pop_back()


func get_resource():
	var current_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
	return current_loaded_resource


func change_scene_to_resource() -> void:
	var err = get_tree().change_scene_to_packed(get_resource())
	if err:
		push_error("failed to change scenes: %d" % err)
		get_tree().quit()


func appear() -> void:
	GameState.in_cinematic = true
	control_root.mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	progress = 0.0
	visibility = 0.0
	animator.play("appear")


func disappear() -> void:
	control_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	animator.play("disappear")
	await animator.animation_finished
	GameState.in_cinematic = false
	visible = false


func _set_progress(_progress: float) -> void:
	progress = _progress
	var mat: ShaderMaterial = bg.material as ShaderMaterial
	mat.set_shader_parameter("progress", progress)

func _set_visibility( _visibility: float ) -> void:
	visibility = clampf(_visibility, 0, 1)
	var mat: ShaderMaterial = bg.material as ShaderMaterial
	mat.set_shader_parameter("visibility", visibility)
