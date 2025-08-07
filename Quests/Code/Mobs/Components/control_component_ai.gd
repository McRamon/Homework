extends ControlComponent
class_name ControlComponentAi

@export var navigator: NavigationAgent2D

var current_target: Vector2 = Vector2.ZERO


func _ready():
	set_physics_process(true)
		
func set_target(target_pos: Vector2):
	current_target = target_pos
	navigator.target_position = target_pos

func get_movement_input() -> Vector2:
	if navigator.is_navigation_finished():
		return Vector2.ZERO
	var next_point = navigator.get_next_path_position()
	return (next_point - owner.global_position).normalized()


#extends Node
#class_name ControlComponent
#
#var movement_component: Node
#
#func _ready():
	#await get_tree().process_frame
	#set_physics_process(true)
#
#func _physics_process(delta: float) ->void:
	#pass
#
#func get_movement_input() -> Vector2:
	#return Vector2.ZERO
