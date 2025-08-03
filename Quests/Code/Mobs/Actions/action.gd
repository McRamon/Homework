extends Node
class_name Action

var user: CharacterBody2D
var direction: Vector2

var cooldown: float = 0.0
var _on_cooldown:= false

func can_activate() -> bool:
	return not _on_cooldown

func activate(mob: CharacterBody2D, direction: Vector2):
	if _on_cooldown:
		return false
	_start_cooldown()
	
func _start_cooldown():
	_on_cooldown = true
	get_tree().create_timer(cooldown).timeout.connect(_reset_cooldown)
	print("attack is on cooldown")
	
func _reset_cooldown():
	_on_cooldown = false
	print("weapon is ready")
