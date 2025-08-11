extends Node
class_name ControlComponent

var movement_component: Node

func _ready():
	await get_tree().process_frame
	set_physics_process(true)

func _physics_process(delta: float) ->void:
	pass

func get_movement_input() -> Vector2:
	return Vector2.ZERO
	
