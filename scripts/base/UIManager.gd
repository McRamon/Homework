extends CanvasLayer

@onready var wood_label  : Label = $wood_label
@onready var stone_label : Label = $stone_label
@onready var food_label  : Label = $food_label
 # Кнопка постройки

# Добавь путь до твоего менеджера построек (укажи правильный, если структура другая!)
@onready var build_manager = get_tree().get_root().get_node("Main/BuildingManager")
@onready var building_manager = $"../BuildingManager"
@onready var house_button = $HouseButton
@onready var barn_button  = $BarnButton
@onready var mill_button  = $MillButton


func _ready() -> void:
	# Инициализация при старте
	_on_resource_changed("wood",  ResourceManager.resources["wood"])
	_on_resource_changed("stone", ResourceManager.resources["stone"])
	_on_resource_changed("food",  ResourceManager.resources["food"])
	# Подписка на изменения ресурсов
	ResourceManager.connect("resource_changed", Callable(self, "_on_resource_changed"))
	# Подключаем обработчик нажатия на кнопку
	
	house_button.pressed.connect(building_manager.request_build_house)
	barn_button.pressed.connect(building_manager.request_build_barn)
	mill_button.pressed.connect(building_manager.request_build_mill)
	
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
	print("Обновляем ресурс:", type, amount)

func _on_build_button_pressed():
	print("Нажата кнопка Построить!")
	# Вызов функции строительства через менеджер
	if build_manager:
		build_manager.request_build_house() # или request_build_barn() и т.д.
	else:
		print("❌ Не найден BuildingManager в дереве!")
