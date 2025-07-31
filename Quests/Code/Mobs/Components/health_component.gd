extends Node
class_name HealthComponent

signal died
signal health_changed(old_value, new_value)

@export var max_health := 100
var current_health: int


func _ready():
	current_health = max_health
	
func take_damage(amount: int):
	var old_health = current_health
	current_health = max(0, current_health - amount)
	
	if current_health <= 0:
		emit_signal("died")
		_on_death()
	else:
		emit_signal("health_changed", old_health, current_health)
		
		
func _on_death():
	get_parent().queue_free()
	
func restore_health(amount: int):
	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", old_health, current_health)
	
