extends Control

@onready var resources_box = $ResourcesBox

var resource_labels: Dictionary = {}  # { "wood": Label }
var resource_icons: Dictionary = {}   # { "wood": AnimatedSprite2D }

func _ready():
	ResourceManager.connect("resource_changed", Callable(self, "_on_resource_changed"))

	# Создаем UI для всех ресурсов, которые уже есть
	for id in ResourceManager.resources.keys():
		_create_resource_ui(id)

func _create_resource_ui(id: String):
	if resource_labels.has(id):
		return

	var container = VBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# 🔹 Получаем Item по id
	var item: Item = ResourceManager.get_item(id)

	# 🔹 AnimatedSprite2D для иконки
	var icon = AnimatedSprite2D.new()
	icon.sprite_frames = item.spritesheet
	icon.play(item.get_animation("ui"))  # ищет анимацию *_ui_icon
	icon.scale = Vector2(2, 2)           # можно увеличить
	container.add_child(icon)
	resource_icons[id] = icon

	# 🔹 Label для количества
	var label = Label.new()
	label.text = str(ResourceManager.get_amount(id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)

	resources_box.add_child(container)
	resource_labels[id] = label

func _on_resource_changed(type: String, amount: int):
	if not resource_labels.has(type):
		_create_resource_ui(type)
	resource_labels[type].text = str(amount)
