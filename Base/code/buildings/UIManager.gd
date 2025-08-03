extends CanvasLayer

@onready var resources_box = $ResourcesBox   # HBoxContainer в сцене

var labels := {}

func _ready():
	ResourceManager.connect("resource_changed", Callable(self, "_on_resource_changed"))

	# Создаём UI для всех ресурсов
	for id in ResourceManager.resources.keys():
		_add_resource_ui(id, ResourceManager.resources[id])

func _add_resource_ui(id: String, amount: int):
	var box = HBoxContainer.new()

	var icon_rect = TextureRect.new()
	icon_rect.texture = ResourceManager.resource_icons.get(id, null)
	icon_rect.custom_minimum_size = Vector2(24, 24)
	box.add_child(icon_rect)

	var lbl = Label.new()
	lbl.text = str(amount)
	box.add_child(lbl)

	resources_box.add_child(box)
	labels[id] = lbl

func _on_resource_changed(type: String, amount: int):
	if labels.has(type):
		labels[type].text = str(amount)
