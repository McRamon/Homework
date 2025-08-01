extends AnimatedSprite2D
class_name WeaponEffect

@export var damage: int = 10
var user: CharacterBody2D
var hit_targets = []

func _ready():
	play("swing")
	animation_finished.connect(queue_free)
	
	var area = get_node_or_null("attack_zone")
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body == user or body in hit_targets:
		return
	hit_targets.append(body)
	
	if body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("take_damage"):
		body.get_node("HealthComponent").take_damage(damage)
