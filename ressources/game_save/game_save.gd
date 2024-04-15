class_name GameSave extends Resource

const SAVE_PATH: String = "user://saved_game.tres"
const start_level_path: String = "res://game/levels/level_0.tscn"

@export var level: int = 0
@export var level_path: String = start_level_path
@export var level_check_point_id: int = 0
@export var show_commands := true


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)


static func load_or_create() -> GameSave:
	var res: GameSave = SafeResourceLoader.load(SAVE_PATH) as GameSave
	if not res:
		res = GameSave.new()
	return res


static func reset() -> GameSave:
	var res: GameSave = GameSave.new()
	return res
