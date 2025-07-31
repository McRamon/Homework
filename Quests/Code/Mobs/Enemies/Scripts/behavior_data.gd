extends Resource
class_name AiBehaviorData


var target_position: Vector2
var direction:= Vector2.ZERO

var user: CharacterBody2D

func set_user(mob: CharacterBody2D):
	user = mob

func get_new_target() -> Vector2:
	return Vector2.ZERO
