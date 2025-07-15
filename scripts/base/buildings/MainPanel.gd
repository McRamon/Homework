extends Control

@onready var produce_button = $ProduceButton
@onready var status_label = $StatusLabel
@onready var timer = $ProductionTimer

var resource_count := 10  # Сколько у тебя есть ресурсов
var product_count := 0    # Сколько готовых продуктов
var recipe_cost := 3      # Сколько ресурсов тратится на 1 производство

func _ready():
	update_status()
	produce_button.pressed.connect(_on_produce_pressed)
	timer.timeout.connect(_on_production_finished)

func _on_produce_pressed():
	if resource_count >= recipe_cost:
		resource_count -= recipe_cost         # Резервируем ресурс
		status_label.text = "Готовим продукт..."
		produce_button.disabled = true
		timer.start(2.0)                     # Время производства, 2 секунды
	else:
		status_label.text = "Недостаточно ресурсов!"

func _on_production_finished():
	product_count += 1
	update_status()
	produce_button.disabled = false

func update_status():
	status_label.text = "Ресурсов: %d\nПродуктов: %d" % [resource_count, product_count]
