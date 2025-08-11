extends Action
class_name UseItem

@export var item: Item

func _ready():
	if item:
		cooldown = item.cooldown
	
func activate(user: CharacterBody2D, direction: Vector2):
	if !super(user, direction):
		return
	if not item:
		return
	item.use(user, direction, self)
	
func _on_mob_hit(body: CharacterBody2D, damage, type):
	if body and body.health_component:
		body.health_component.take_damage(damage, type)
	
	#
	#if body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("take_damage"):
		#var randomized_damage = int(round(item.damage * randf_range(0.8, 1.1)))
		#body.health_component.take_damage(randomized_damage)
		#
	#if item.status_effects and body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("apply_status_effect"):
		#for i in item.status_effects:
			#body.get_node("HealthComponent").apply_status_effect(i)
	#if body.has_node("AnimationComponent"):
		##var direction = user.global_position.direction_to(body.global_position)
		#body.animation_component.push(direction, item.force)
		#print(body, " is pushed in the direction ", direction, " with force: ", item.force)
