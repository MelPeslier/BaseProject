class_name UserAudioPreferences
extends Resource

const SAVE_PATH: String = "user://user_audio_prefs.tres"

@export var volumes: Array[float] = [1, 1, 1, 1]

func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> UserAudioPreferences:
	var res: UserAudioPreferences = SafeResourceLoader.load(SAVE_PATH) as UserAudioPreferences
	if not res:
		res = UserAudioPreferences.reset()
	return res

static func reset() -> UserAudioPreferences:
	var res: UserAudioPreferences = UserAudioPreferences.new()
	res.save()
	return res
