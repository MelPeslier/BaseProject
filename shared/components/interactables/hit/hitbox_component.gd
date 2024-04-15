class_name HitboxComponent
extends Area2D

signal hit_gived_at(_pos: Vector2)

@export var parent: Node2D
@export var attack_data: AttackData
@export var energy_component: EnergyComponent
@onready var collision_shape = get_child(0)


func _init() -> void:
	collision_layer = 2
	collision_mask = 0

func deactivate() -> void:
	collision_shape.set_deferred("disabled", true)


func activate() -> void:
	collision_shape.disabled = false
