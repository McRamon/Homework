extends Control

@export var recipes: Array[BuildingData]    # список доступных зданий
@export var max_queue: int = 3              # ограничение очереди

@onready var recipes_container = $HBoxContainer/RecipesContainer
@onready var queue_container = $HBoxContainer/QueueContainer

var queue: Array[BuildingData] = []

func _ready():
	_populate_recipes()

# 🔹 Создание кнопок зданий
func _populate_recipes():
	for child in recipes_container.get_children():
		child.queue_free()

	for recipe in recipes:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.custom_minimum_size = Vector2(100, 140)

		# 🏷️ Название
		var name_label = Label.new()
		name_label.text = recipe.name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_label)

		# 🖼️ Кнопка с иконкой
		var btn = TextureButton.new()
		btn.texture_normal = recipe.icon_preview
		btn.custom_minimum_size = Vector2(64, 64)
		btn.connect("pressed", Callable(self, "_on_recipe_pressed").bind(recipe))
		vbox.add_child(btn)

		# 💰 Стоимость
		var cost_label = Label.new()
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.name = "CostLabel"
		cost_label.text = _format_cost(recipe.cost)

		# Проверка ресурсов
		var can_afford = ResourceManager.can_afford(recipe.cost)
		if can_afford:
			cost_label.add_theme_color_override("font_color", Color(0, 1, 0)) # зелёный
			btn.disabled = false
		else:
			cost_label.add_theme_color_override("font_color", Color(1, 0, 0)) # красный
			btn.disabled = true

		vbox.add_child(cost_label)

		recipes_container.add_child(vbox)

# 🔹 Добавление в очередь
func _on_recipe_pressed(recipe: BuildingData):
	if queue.size() >= max_queue:
		print("❌ Очередь заполнена!")
		return

	queue.append(recipe)
	print("✅ Добавлено в очередь:", recipe.name)
	_update_queue_ui()

# 🔹 Обновление UI очереди
func _update_queue_ui():
	for child in queue_container.get_children():
		child.queue_free()

	for item in queue:
		var lbl = Label.new()
		lbl.text = item.name
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color.BLUE)
		queue_container.add_child(lbl)

# 🔹 Форматирование стоимости
func _format_cost(cost: Dictionary) -> String:
	var parts = []
	for k in cost.keys():
		parts.append("%s: %d" % [str(k), cost[k]])
	return ", ".join(parts)
