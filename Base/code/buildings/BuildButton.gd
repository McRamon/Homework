extends Button

@export var building_data: BuildingData
@onready var manager = $"../BuildingManager"

var name_label: Label
var icon_rect: TextureRect
var cost_box: VBoxContainer

func _ready():
	text = ""
	icon = null

	for c in get_children():
		c.queue_free()

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(48, 48)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(icon_rect)

	cost_box = VBoxContainer.new()
	vbox.add_child(cost_box)

	_update_ui()

	pressed.connect(Callable(self, "_on_pressed"))

func _update_ui():
	if building_data:
		name_label.text = building_data.name
		icon_rect.texture = building_data.menu_icon
		_update_cost_icons(building_data.build_requirements)

		var can_build = ResourceManager.can_afford(building_data.build_requirements)
		disabled = not can_build
		modulate.a = 1.0 if can_build else 0.5

func _update_cost_icons(requirements: Array):
	for child in cost_box.get_children():
		child.queue_free()

	for req in requirements:
		var res: Item = req["resource"]
		var amount = req["amount"]

		var hbox = HBoxContainer.new()

		var icon_tex = TextureRect.new()
		icon_tex.texture = res.spritesheet.get_frame_texture(res.get_animation("ui"), 0)
		icon_tex.custom_minimum_size = Vector2(16, 16)
		hbox.add_child(icon_tex)

		var lbl = Label.new()
		lbl.text = str(amount)
		hbox.add_child(lbl)

		cost_box.add_child(hbox)

func _on_pressed():
	manager.request_build(building_data) # ✅ Только активируем режим постройки, без диалога
