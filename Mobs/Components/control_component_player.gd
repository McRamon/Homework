extends ControlComponent
class_name ControlComponentPlayer

var input_direction:= Vector2.ZERO
var enabled: bool = true
var last_dir: Vector2 = Vector2.ZERO

@export var action_control: ActionControl 

func _physics_process(delta: float) ->void:
	player_input()


func get_movement_input() -> Vector2:
	if enabled:
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		last_dir = input_direction
		return input_direction
	else:
		return last_dir
	
func player_input():
	if Input.is_action_just_pressed("mouse_left"):
		if get_viewport().gui_get_hovered_control() != null:
			return
		asskick(owner, get_attack_direction())
		print(owner, " pressed LMB")
	if Input.is_action_just_pressed("ability"):
		use_ability(owner, get_attack_direction())
		print(owner, " pressed Space")
	if Input.is_action_just_pressed("use"):
		use_action_use_item(owner, get_attack_direction())
		
func get_attack_direction() -> Vector2:
	var direction = (owner.get_global_mouse_position() - owner.global_position).normalized()
	return direction
	
func use_action_use_item(mob: CharacterBody2D, direction: Vector2):
	pass
	
func use_ability(mob, vector):
	action_control.activate_ability(mob, vector)

		
func asskick(mob, vector):
	action_control.use_weapon(vector)
