class_name EnergyComponent
extends Node

signal energy_updated(_energy: float, _max_energy:  float)

@export var max_energy: float
@export var energy: float: set = _set_energy


func have(energy_cost: float) -> bool:
	return energy_cost <= energy


func use(amount: float) -> void:
	energy -= amount


func gain(amount: float) -> void:
	energy += amount


func _set_energy(val) -> void:
	energy = clampf(val, 0, max_energy)
	energy_updated.emit(energy, max_energy)
