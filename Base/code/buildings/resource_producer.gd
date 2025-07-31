# resource_producer.gd
extends Node2D

@export var resource_type: String = "food"
@export var amount: int = 1

@onready var timer: Timer = $Timer

func _ready():
	timer.connect("timeout", _on_timeout)
	timer.start()

func _on_timeout():
	ResourceManager.add_resource(resource_type, amount)
	
	
func start_production():
	timer.start()
