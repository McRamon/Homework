# ProductionPassive.gd
extends Node2D

@export var resource_type: String = "food"
@export var amount: int = 1
@export var interval: float = 5.0

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = interval
	timer.timeout.connect(_on_timeout)
	timer.start()

func start_production():
	timer.start() # Можно перезапустить при завершении постройки

func _on_timeout():
	ResourceManager.add_resource(resource_type, amount)
	timer.start()
