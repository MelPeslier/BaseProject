class_name UserDisplayPreferences
extends Resource


const SAVE_PATH: String = "user://user_display_prefs.tres"

@export var actual_screen: int = DisplayServer.get_primary_screen()
@export var display_mode: String = Parameters.display_modes.find_key(Parameters.display_modes.FULL_SCREEN)
@export var resolution: Vector2i = Parameters.resolutions[1]
@export var screen_anchor: String = Parameters.screen_anchors.find_key(Parameters.screen_anchors.CENTER)
@export var v_sync: String = Parameters.v_syncs.find_key(Parameters.v_syncs.V_SYNC_ENABLED)
@export var framerate_limit: int = Parameters.framerate_limits[1]
@export var show_framerate: bool = false
@export var constrain_mouse: bool = true
@export var ui_scale: float = 1


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> UserDisplayPreferences:
	var res: UserDisplayPreferences = SafeResourceLoader.load(SAVE_PATH) as UserDisplayPreferences
	if not res:
		res = UserDisplayPreferences.reset()
	return res

static func reset() -> UserDisplayPreferences:
	var res: UserDisplayPreferences = UserDisplayPreferences.new()
	res.save()
	return res
