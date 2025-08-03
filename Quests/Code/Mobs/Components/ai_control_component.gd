extends ControlComponent
class_name ControlComponentAi

@export var behavior_data: AiBehaviorData


func _ready():
	set_physics_process(true)
	if behavior_data:
		behavior_data.set_user(owner)

func get_movement_input() -> Vector2:
	var target = behavior_data.get_new_target()
	var direction = owner.global_position - target
	return direction
