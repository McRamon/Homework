extends ControlComponent
class_name ControlComponentPlayer

var input_direction:= Vector2.ZERO
var enabled: bool = true
var last_dir: Vector2 = Vector2.ZERO

var action_use_item: Action
var ability: Action

func _ready():
	super()
	if $action_use_item:
		action_use_item = $action_use_item
	if $ability:
		ability = $ability
	print(owner)

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
		use_action_use_item(owner, get_attack_direction())
		print(owner, " pressed LMB")
	if Input.is_action_just_pressed("ability"):
		use_ability(owner, get_attack_direction())
		print(owner, " pressed Space")
		
func get_attack_direction() -> Vector2:
	var direction = (owner.get_global_mouse_position() - owner.global_position).normalized()
	return direction
	
func use_action_use_item(mob: CharacterBody2D, direction: Vector2):
	if action_use_item:
		action_use_item.activate(mob, direction)
	else:
		print("no attack main detected")
	
func use_ability(mob, vector):
	if ability:
		ability.activate(mob, vector)
	else:
		push_error(" NULL ability ")
