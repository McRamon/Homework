extends WeaponEffect
class_name RangedWeaponEffect

@export var speed: float = 1000.0
@export var distance: float = 500.0
@export var piercing:= false

var direction: Vector2
var travelled_distance: float = 0.0

signal distance_reached

func _process(delta):
	var step = speed * delta
	global_position += direction * step
	travelled_distance += step
	if travelled_distance >= distance:
		emit_signal("distance_reached")
		queue_free()
		
func _on_body_entered(body: Node2D):
	super(body)
	if !piercing:
		queue_free()

func get_animation_name() -> String:
	return "projectile"

func get_area_name() -> String:
	return "collision_zone"
