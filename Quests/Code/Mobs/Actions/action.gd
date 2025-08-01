extends Resource
class_name Action

@export var cooldown: float
var _on_cooldown:= false

func activate(mob: CharacterBody2D, direction: Vector2):
	if _on_cooldown:
		return false
	_on_cooldown = true
	
	var timer = mob.get_tree().create_timer(cooldown)
	print("attack is on cooldown")
	timer.timeout.connect(_reset_cooldown)
	
	return true
	
func update(delta: float):
	pass
	
func _reset_cooldown():
	_on_cooldown = false
	print("weapon is ready")
