extends BaseWeaponEffect
class_name RangedWeaponEffect

@export var speed: float = 1000.0
@export var distance: float = 500.0
@export var piercing:= false

var direction: Vector2
var travelled_distance: float = 0.0

func _process(delta):
	var step = speed * delta
	global_position += direction * step
	travelled_distance += step
	if travelled_distance >= distance:
		queue_free()
		
func _on_body_entered(body: Node2D):
	super(body)
	if !piercing:
		queue_free()

func get_animation_name() -> String:
	return "projectile"

func get_area_name() -> String:
	return "collision_zone"


#extends AnimatedSprite2D
#class_name RangedWeaponEffect
#
#@export var speed: float = 1000.0
#@export var distance: float = 500.0
#@export var damage: int = 10
#@export var piercing: bool = false
#
#var direction: Vector2
#var travelled_distance: float = 0.0
#var user: CharacterBody2D
#var hit_targets = []
#
#func _ready():
	#play("projectile")
	#var area = get_node_or_null("collision_zone")
	#if area:
		#area.body_entered.connect(_on_body_entered)
#
#func _process(delta):
	#var step = speed * delta
	#global_position += direction * step
	#travelled_distance += step
	#if travelled_distance >= distance:
		#queue_free()
#
#func _on_body_entered(body: Node2D):
	#if body == user or body in hit_targets:
		#return
	#hit_targets.append(body)
#
	#if body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("take_damage"):
		#body.get_node("HealthComponent").take_damage(damage)
#
	#if not piercing:
		#queue_free()
