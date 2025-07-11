extends CanvasLayer

@onready var wood_label  : Label = $wood_label
@onready var stone_label : Label = $stone_label
@onready var food_label  : Label = $food_label

func _ready() -> void:
	# Инициализация при старте
	_on_resource_changed("wood",  ResourceManager.resources["wood"])
	_on_resource_changed("stone", ResourceManager.resources["stone"])
	_on_resource_changed("food",  ResourceManager.resources["food"])
	# Подписка на изменения
	ResourceManager.connect("resource_changed", Callable(self, "_on_resource_changed"))
	

func _on_resource_changed(type: String, amount: int) -> void:
	match type:
		"wood":
			wood_label.text  = "Wood: %d"  % amount
		"stone":
			stone_label.text = "Stone: %d" % amount
		"food":
			food_label.text  = "Food: %d"  % amount
		_:
			pass
	print("Обновляем ресурс:", type, amount) # ← это должно появиться в Output
