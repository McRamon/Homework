extends Node2D

@export var resource_type: String = "food"
@export var amount: int = 1

@onready var timer: Timer = $Timer

func _ready():
	print("PRODUCER READY!")
	timer.connect("timeout", _on_timeout)

func _on_timeout():
	print("==> Добавляем ресурс:", resource_type, "+", amount)
	ResourceManager.add_resource(resource_type, amount)
	timer.start()

func start_production():
	print("==> Старт производства!")
	timer.start()
