class_name UserGamePreferences
extends Resource

const SAVE_PATH: String = "user://user_game_prefs.tres"

@export var language: String = ""

func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> UserGamePreferences:
	var res: UserGamePreferences = SafeResourceLoader.load(SAVE_PATH) as UserGamePreferences
	if not res:
		res = UserGamePreferences.reset()
	return res

static func reset() -> UserGamePreferences:
	var res: UserGamePreferences = UserGamePreferences.new()
	res.save()
	return res
