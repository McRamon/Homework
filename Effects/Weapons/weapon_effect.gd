extends AnimatedSprite2D
class_name WeaponEffect

var direction: Vector2
var user: CharacterBody2D
var hit_targets: Array = []
var weapon_data: ItemWeapon

signal mob_hit(mob: CharacterBody2D)

func _ready():
	play(get_animation_name())
	var area = get_node_or_null(get_area_name())
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body == user or body in hit_targets:
		return
	hit_targets.append(body)
	
	emit_signal("mob_hit", body)

# --- Virtual Methods for Children ---
func get_animation_name() -> String:
	return "default"

func get_area_name() -> String:
	return "collision_zone"
