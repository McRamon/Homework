extends Node2D

@export var recipes: Array[Recipe] = []
@onready var TimerNode: Timer = $Timer
@onready var StatusLabel: Label = $StatusLabel

var queue: Array[Recipe] = []
var current_recipe: Recipe = null
var time_left: float = 0.0

func _ready():
	TimerNode.one_shot = true
	TimerNode.timeout.connect(_on_craft_complete)
	update_status()

func add_to_queue(recipe: Recipe):
	queue.append(recipe)
	if current_recipe == null:
		_start_next_recipe()
	update_status()

func _start_next_recipe():
	if queue.is_empty():
		current_recipe = null
		update_status()
		return

	current_recipe = queue.pop_front()
	time_left = current_recipe.duration
	StatusLabel.text = "Крафтим: %s (%.1f сек)" % [current_recipe.name, time_left]
	TimerNode.start(current_recipe.duration)

func _on_craft_complete():
	# Выдать ресурсы
	for k in current_recipe.output.keys():
		ResourceManager.add_resource(k, current_recipe.output[k])

	StatusLabel.text = "Готово: %s!" % current_recipe.name
	current_recipe = null
	_start_next_recipe()

func update_status():
	if current_recipe:
		StatusLabel.text = "Крафтим: %s (%.1f сек)" % [current_recipe.name, time_left]
	elif queue.size() > 0:
		StatusLabel.text = "В очереди: %d" % queue.size()
	else:
		StatusLabel.text = "Станция свободна"
