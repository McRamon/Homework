extends AnimatedSprite2D
class_name BaseWeaponEffect

@export var damage: int = 10
var user: CharacterBody2D
var hit_targets: Array = []

@export var status_effect_list: Array[StatusEffect] = []

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
		body.get_node("HealthComponent").take_damage(damage)
		
	if status_effect_list and body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("apply_status_effect"):
		for i in status_effect_list:
			body.get_node("HealthComponent").apply_status_effect(i)

# --- Virtual Methods for Children ---
func get_animation_name() -> String:
	return "default"

func get_area_name() -> String:
	return "collision_zone"
