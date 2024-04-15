class_name MyRng
extends Node

static var rng := RandomNumberGenerator.new()

static func get_random(val: float, diff: float) -> float:
	return rng.randf_range( val - diff, val + diff )
