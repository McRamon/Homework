extends Resource
class_name StatusEffect

@export var effect_name: String = "Unnamed Effect"
@export var description: String = "This should not appear, fix the bug"
@export var duration: float = 1.0  # in seconds
@export var icon: Texture2D


var elapsed_time: float = 0.0

func on_apply(target: Node):
	pass

func on_update(target: Node, delta: float) -> bool:
	if duration == 0:
		return false
	elapsed_time += delta
	return elapsed_time >= duration 

func on_expire(target: Node):
	if target.has_method("remove_status_effect"):
		target.remove_status_effect(self)
