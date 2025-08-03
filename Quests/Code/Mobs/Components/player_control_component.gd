extends ControlComponent
class_name ControlComponentPlayer

var input_direction:= Vector2.ZERO
var enabled: bool = true
var last_dir: Vector2 = Vector2.ZERO

func _ready():
	super()
	print(owner)

func _physics_process(delta: float) ->void:
	super(delta)
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
		use_attack_main(owner, get_attack_direction())
		print(owner, " pressed LMB")
	if Input.is_action_just_pressed("mouse_right"):
		print(owner, " pressed RMB")
		use_attack_secondary(owner, get_attack_direction())
	if Input.is_action_just_pressed("ability"):
		use_ability(owner, get_attack_direction())
		print(owner, " pressed Space")
		
func get_attack_direction() -> Vector2:
	var direction = (owner.get_global_mouse_position() - owner.global_position).normalized()
	return direction
