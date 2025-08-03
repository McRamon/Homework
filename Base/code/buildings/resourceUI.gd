extends CanvasLayer

@onready var resources_container: HBoxContainer = $ResourcesContainer

var resource_labels: Dictionary = {}  # { "wood": Label, "stone": Label }

func _ready():
	# Подписываемся на изменения ресурсов
	ResourceManager.connect("resource_changed", Callable(self, "_on_resource_changed"))

	# ✅ Создаём UI для всех ресурсов, зарегистрированных в ResourceManager
	for id in ResourceManager.resources.keys():
		_create_resource_ui(id, ResourceManager.get_amount(id))

func _create_resource_ui(id: String, amount: int):
	# Основной контейнер
	var box = HBoxContainer.new()

	# 🖼️ Иконка ресурса
	var icon_rect = TextureRect.new()
	icon_rect.texture = ResourceManager.resource_icons[id]
	icon_rect.custom_minimum_size = Vector2(24, 24)
	box.add_child(icon_rect)

	# 🔢 Количество
	var lbl = Label.new()
	lbl.text = str(amount)
	box.add_child(lbl)

	resources_container.add_child(box)
	resource_labels[id] = lbl

func _on_resource_changed(id: String, amount: int):
	if resource_labels.has(id):
		resource_labels[id].text = str(amount)
	else:
		# Если ресурс добавился впервые – создаём UI для него
		_create_resource_ui(id, amount)
