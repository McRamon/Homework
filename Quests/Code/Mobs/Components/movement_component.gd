extends Node
class_name MovementComponent

@export var max_speed := 500.0              # Pixels/second
@export var acceleration := 1500.0          # How quickly player reaches max speed
@export var deceleration := 1000.0          # How quickly player stops
@export var friction := 0.95

@export var control_component: ControlComponent

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var enabled:= true


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
		
	velocity *= friction
	
	if velocity > Vector2.ZERO:
		var animation_component = get_parent().get_node_or_null("AnimationComponent")
		animation_component.animation_walk()
	else:
		var animation_component = get_parent().get_node_or_null("AnimationComponent")
		animation_component.animation_idle()	


	
