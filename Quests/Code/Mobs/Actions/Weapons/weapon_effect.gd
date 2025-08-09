extends AnimatedSprite2D
class_name WeaponEffect

@export var damage: int = 10
@export var force: int = 0
var direction: Vector2
var user: CharacterBody2D
var hit_targets: Array = []
var weapon_data: ItemWeapon

func _ready():
	play(get_animation_name())
	var area = get_node_or_null(get_area_name())
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body == user or body in hit_targets:
		return
	hit_targets.append(body)
	
	if body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("take_damage"):
		var randomized_damage = int(round(damage * randf_range(0.8, 1.1)))
		body.health_component.take_damage(randomized_damage)
		
	if weapon_data.status_effects and body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("apply_status_effect"):
		for i in weapon_data.status_effects:
			body.get_node("HealthComponent").apply_status_effect(i)
	if body.has_node("AnimationComponent"):
		#var direction = user.global_position.direction_to(body.global_position)
		body.animation_component.push(direction, force)
		print(body, " is pushed in the direction ", direction, " with force: ", force)

# --- Virtual Methods for Children ---
func get_animation_name() -> String:
	return "default"

func get_area_name() -> String:
	return "collision_zone"
