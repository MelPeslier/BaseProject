extends Node

var in_game := false
var in_cinematic := false

# For main menu to know how to transite song
var game_started := false

var saved_game: GameSave

func _ready() -> void:
	saved_game = GameSave.load_or_create()


func has_saved_game() -> bool:
	return saved_game.level == 0


func save_game() -> void:
	saved_game.save()


func new_game() -> void:
	saved_game = GameSave.reset()


func can_pause() -> bool:
	return not in_cinematic

