extends CanvasLayer

var _scene_path: String = ""
var transition_screen: TransitionScreen
var is_reload_scene := false


func _init() -> void:
	layer = GameLayer.Layer.TRANSITION_SCREEN


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var status = get_status()
	transition_screen.progress = get_progress()

	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			push_warning("Couldn't load resource, wrong status : ", + status)
			set_process(false)
			transition_screen.disappear()

		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)

#region Reload
func reload_current_scene(_transition_screen_packed : PackedScene) -> void:
	instantiate_transition_screen(_transition_screen_packed)
	transition_screen.appeared.connect(_on_transition_screen_appeared)
	transition_screen.appear()

func _on_transition_screen_appeared() -> void:
	transition_screen.progress_filled.connect(_on_progress_filled)
	transition_screen.progress = 1.0
	var err := get_tree().reload_current_scene()
	if not err == OK:
		push_error("Couldn't reload scene")
		get_tree().quit()

func _on_progress_filled() -> void:
	transition_screen.disappear()
	transition_screen = null
#endregion

#region Change to different scene
func change_scene(_target_path: String, _transition_screen_packed : PackedScene) -> void:
	instantiate_transition_screen(_transition_screen_packed)
	transition_screen.change_scene_available.connect(_on_change_scene_available)
	_scene_path = _target_path
	transition_screen.appear()
	ResourceLoader.load_threaded_request( _scene_path )
	set_process(true)

func _on_change_scene_available() -> void:
	change_scene_to_resource()
	print("changed scene")
	transition_screen.disappear()
#endregion

func instantiate_transition_screen(_packed_scene: PackedScene) -> void:
	transition_screen = _packed_scene.instantiate() as TransitionScreen
	if not transition_screen is TransitionScreen:
		push_warning("SceneTransition has been passed the wrong file type")
		transition_screen = null
		return
	add_child(transition_screen)


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
