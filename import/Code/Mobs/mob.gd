extends CharacterBody2D
class_name Mob

@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var control_component: ControlComponent

func _ready():
	health_component.died.connect(_on_death)
	health_component.health_changed.connect(_on_health_change)
	

func _physics_process(delta: float):
	movement_component._physics_process(delta)
	velocity = movement_component.velocity
	move_and_slide()
	
	var sprite = $mob_sprite
	
	if velocity.x < 0 and not sprite.flip_h:
		sprite.flip_h = true
	elif velocity.x > 0 and sprite.flip_h:
		sprite.flip_h = false


func _on_death():
	pass
	
func _on_health_change():
	pass
