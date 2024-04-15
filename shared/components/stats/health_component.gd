class_name HealthComponent
extends Node

signal health_changed(_health: float, _max_health: float)
signal health_damaged(_damage_amount: float)
signal health_healed(_heal_amount: float)

@export var max_health: float
@export var health: float = 1: set = _set_health
var alive := true


func damage(_damage: float) -> void:
	health -= _damage
	health_damaged.emit(_damage)


func heal(amount: float) -> void:
	health += amount
	health_healed.emit(amount)


func _set_health(_health: float) -> void:
	health = clampf(_health, 0, max_health)
	if health == 0:
		alive = false
	health_changed.emit(health, max_health)
