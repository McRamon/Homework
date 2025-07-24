extends Node2D
class_name Mob

#Components
@export var health_component: HealthComponent
@export var movement_component: Node
@export var status_effect_component: Node
@export var animation_component: AnimationComponent

#Nodes
@export var sprite: Node2D
@export var collider: Area2D


func _ready():
	health_component.damage_taken.connect(_on_damage_taken)
	animation_component.play_animation_idle()
	
	
	
func _on_damage_taken(amount: int) -> void:
	pass
