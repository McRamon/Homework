extends Node
class_name HealthComponent

@export var health_max := 100
var health_current: int

signal damage_taken
signal health_zero

func _ready():
	health_current = health_max
	
func take_damage(amount: int):
	health_current = clamp(health_current - amount, 0, health_max)
	damage_taken.emit(amount)
	
	if health_current == 0:
		health_zero.emit()
	

func restore_health(amount: int):
	health_current = clamp(health_current + amount, 0, health_max)
	
func get_health_percent() -> float:
	return float(health_current) / float(health_max)
	
func rejuvenate():
	health_current = health_max
	
	if get_parent().has_node("StatusEffectComponent"):
		get_parent().get_node("statusEffectComponent").remove_all_negative()
