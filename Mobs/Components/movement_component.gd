extends Node
class_name MovementComponent

@export var max_speed := 400.0              # Pixels/second       # How quickly player stops

@export var control_component: ControlComponent
@export var navigator: NavigationAgent2D

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var enabled:= true

var external_velocity := Vector2.ZERO

func _ready():
	max_speed = owner.speed


func _physics_process(delta: float) -> void:
	if !enabled:
		return
	if control_component:
			direction = control_component.get_movement_input()
		
	var new_velocity = direction * max_speed
	if external_velocity != Vector2.ZERO:
		velocity = new_velocity + external_velocity
	else:
		if navigator:
			if navigator.avoidance_enabled:
				navigator.max_speed = max_speed
				navigator.set_velocity(new_velocity)
			else:
				_on_mob_navigator_velocity_computed(new_velocity)
		else:
			velocity = new_velocity
	
		
	

	


func _on_mob_navigator_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
