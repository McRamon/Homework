extends Control

var station: Node = null
@onready var recipes_ct = $RecipesContainer
@onready var finished_ct = $FinishedContainer
@onready var close_btn = $CloseButton

var slot_nodes: Dictionary = {}   # slot -> TextureButton

func _ready():
	if not close_btn.pressed.is_connected(Callable(self, "_on_CloseButton_pressed")):
		close_btn.pressed.connect(Callable(self, "_on_CloseButton_pressed"))
	# ✅ Подписываемся на изменение ресурсов
	if not ResourceManager.is_connected("resource_changed", Callable(self, "_on_resources_updated")):
		ResourceManager.connect("resource_changed", Callable(self, "_on_resources_updated"))

func open_for_station(crafting_station: Node):
	station = crafting_station
	_populate_recipes()
	_create_finished_slots()
	visible = true
	set_process(true)

func _process(_delta):
	if visible and station:
		_update_finished_progress()

# 🔹 Обновляем доступность рецептов при изменении ресурсов
func _on_resources_updated(_type: String, _amount: int):
	if visible:
		_refresh_recipes_state()

func _populate_recipes():
	for c in recipes_ct.get_children():
		c.queue_free()

	for recipe in station.recipes:
		var container = VBoxContainer.new()
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		container.set_meta("recipe", recipe)  # ✅ сохраняем ссылку на рецепт

		# 🖼️ Кнопка с иконкой
		var btn = TextureButton.new()
		btn.texture_normal = recipe.icon
		btn.custom_minimum_size = Vector2(64, 64)

		var can_afford = ResourceManager.can_afford(recipe.input)
		btn.disabled = not can_afford
		btn.connect("pressed", Callable(self, "_on_recipe_pressed").bind(recipe))
		container.add_child(btn)

		# 💰 Текст с ресурсами
		var cost_label = Label.new()
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.text = _format_cost(recipe.input)
		cost_label.name = "CostLabel"

		if can_afford:
			cost_label.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			cost_label.add_theme_color_override("font_color", Color(1, 0, 0))

		container.add_child(cost_label)
		recipes_ct.add_child(container)

func _refresh_recipes_state():
	for container in recipes_ct.get_children():
		var recipe = container.get_meta("recipe") as Recipe
		if recipe == null:
			continue

		var btn = container.get_child(0) as TextureButton
		var cost_label = container.get_node("CostLabel") as Label
		var can_afford = ResourceManager.can_afford(recipe.input)

		btn.disabled = not can_afford
		if can_afford:
			cost_label.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			cost_label.add_theme_color_override("font_color", Color(1, 0, 0))

func _create_finished_slots():
	for c in finished_ct.get_children():
		c.queue_free()
	slot_nodes.clear()

	for slot in station.finished_slots:
		var ico = TextureButton.new()
		ico.texture_normal = slot["recipe"].icon
		ico.modulate.a = 0.5
		slot["icon"] = ico

		ico.connect("pressed", Callable(self, "_on_collect_pressed").bind(slot))
		finished_ct.add_child(ico)
		slot_nodes[slot] = ico

func _update_finished_progress():
	for slot in station.finished_slots:
		if slot_nodes.has(slot):
			var alpha = 0.5 + 0.5 * (slot["progress"] / slot["time"])
			slot_nodes[slot].modulate.a = clamp(alpha, 0.5, 1.0)

func _on_recipe_pressed(recipe: Recipe):
	station.add_to_queue(recipe)
	_create_finished_slots()
	_refresh_recipes_state()

func _on_collect_pressed(slot):
	if slot["progress"] >= slot["time"]:
		station.collect_slot(slot)
		_create_finished_slots()
		_refresh_recipes_state()

func _on_CloseButton_pressed():
	visible = false
	set_process(false)

func _format_cost(cost: Dictionary) -> String:
	var parts = []
	for k in cost.keys():
		parts.append("%s:%d" % [str(k), cost[k]])
	return ", ".join(parts)
