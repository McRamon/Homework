extends Node
class_name HealthComponent

signal died
signal health_changed(old_value, new_value)

@export var max_health := 100
var current_health: int

@export var starting_status_effects: Array[StatusEffect] = []
var active_status_effects: Array[StatusEffect] = []


func _ready():
	await get_tree().process_frame
	current_health = max_health
	for i in starting_status_effects:
		apply_status_effect(i)
	
	
func _process(delta):
	for i in active_status_effects:
		if i.on_update(self, delta):
			i.on_expire(self)
		active_status_effects = active_status_effects.filter(func(e):
			return e.duration == 0 or e.elapsed_time < e.duration
		)
	
func take_damage(amount: int):
	var old_health = current_health
	current_health = max(0, current_health - amount)
	print(get_parent(), " takes ", amount, " damage")
	
	if current_health <= 0:
		emit_signal("died")
	else:
		emit_signal("health_changed", old_health, current_health)
		
	
func restore_health(amount: int):
	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", old_health, current_health)
	
func apply_status_effect(status_effect):
	var new_effect = status_effect.duplicate()
	for effect in active_status_effects:
		if new_effect.name == effect.name:
			effect.elapsed_time = 0
			return
	active_status_effects.append(new_effect)
	new_effect.on_apply(self)
	
func remove_status_effect(status_effect):
	active_status_effects.erase(status_effect)
	
	
