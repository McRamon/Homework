extends CharacterBody2D
class_name Mob

@export var mob_name: String = "Mob"
@export var mob_description: String = "Standard Mob"
@export var mob_level: int = 1
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var control_component: ControlComponent
@export var animation_component: AnimationComponent


func _ready():
	health_component.died.connect(on_death)
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


func on_death():
	queue_free()
	
func _on_health_change(old_amount, new_amount):
	pass
