extends Node
class_name MovementComponent

@export var max_speed := 400.0              # Pixels/second
@export var acceleration := 1500.0          # How quickly player reaches max speed
@export var deceleration := 1000.0          # How quickly player stops
@export var friction := 0.95

@export var control_component: ControlComponent
@export var navigator: NavigationAgent2D

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var enabled:= true

var external_velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if !enabled:
		return
	if control_component:
			direction = control_component.get_movement_input()
		
	if direction != Vector2.ZERO:
		velocity += direction * acceleration * delta
		velocity = velocity.limit_length(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
		velocity += external_velocity
		if navigator:
			if navigator.avoidance_enabled:
				navigator.set_velocity(velocity)
			else:
				_on_mob_navigator_velocity_computed(velocity)
	
		
	

	


func _on_mob_navigator_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
