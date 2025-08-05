extends Control

@export var building_types: Array[BuildingData] = []

@onready var container = $ButtonsContainer
@onready var info_dialog = $BuildingInfoDialog

func _ready():
	init_build_menu()

func init_build_menu():
	# Очистка старых кнопок
	for child in container.get_children():
		child.queue_free()

	for data in building_types:
		var btn = preload("res://Base/Scenes/building_button.tscn").instantiate()

		# Название постройки
		btn.get_node("NameLabel").text = data.name

		# Установка иконки здания
		var icon_sprite = btn.get_node("Icon") as AnimatedSprite2D
		icon_sprite.sprite_frames = data.spritesheet
		var anim = data.get_animation("ui")
		if anim != "":
			icon_sprite.play(anim)
		else:
			print("⚠ Нет анимации для здания: ", data.name)

		# Обработка нажатия
		btn.pressed.connect(func(): show_info_dialog(data))

		container.add_child(btn)

func show_info_dialog(data: BuildingData):
	info_dialog.get_node("Content/Title").text = data.name
	info_dialog.get_node("Content/DescriptionLabel").text = data.description

	# Установка ресурсов
	var res_icon = info_dialog.get_node("Content/RequirementsContainer/ResourceIcon") as AnimatedSprite2D
	var res_label = info_dialog.get_node("Content/RequirementsContainer/ResourceLabel") as Label

	if data.requirement_items.size() > 0:
		var res_item: Item = data.requirement_items[0]
		var amount = data.requirement_amounts[0]

		if res_item != null and res_item.spritesheet != null:
			res_icon.sprite_frames = res_item.spritesheet
			var anim = res_item.get_animation("ui")
			if anim != "":
				res_icon.play(anim)
			else:
				print("⚠ Нет анимации для ресурса: ", res_item.name)
		else:
			print("⚠ Не удалось загрузить иконку ресурса для: ", data.name)

		res_label.text = "%s " % [amount]
	else:
		res_icon.visible = false
		res_label.text = "Нет требований"

	# Обработка кнопок
	var build_btn = info_dialog.get_node("Content/BuildButton") as Button
	build_btn.disabled = not ResourceManager.can_afford([{
		"resource": data.requirement_items[0],
		"amount": data.requirement_amounts[0]
	}])
	build_btn.pressed.connect(func(): _on_build_confirmed(data), CONNECT_ONE_SHOT)

	var cancel_btn = info_dialog.get_node("Content/CancelButton") as Button
	cancel_btn.pressed.connect(func(): info_dialog.hide(), CONNECT_ONE_SHOT)

	info_dialog.popup_centered()

func _on_build_confirmed(data: BuildingData):
	info_dialog.hide()
	if Engine.has_singleton("BuildingManager"):
		Engine.get_singleton("BuildingManager").enter_build_mode(data)
	elif has_node("/root/BuildingManager"):
		get_node("/root/BuildingManager").enter_build_mode(data)
	else:
		print("❗ BuildingManager не найден в автозагрузке")
