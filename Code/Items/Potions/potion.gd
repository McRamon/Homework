extends Item
class_name ItemPotion

@export var capacity: float = 10.0
@export var heal_amount: float = 10.0
@export var status_effects: Array[StatusEffect] = []
@export var visual_effect: PackedScene


func use(user: CharacterBody2D, direction: Vector2, action: Action = null):
	pass
