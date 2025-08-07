# res://Base/Code/buildings/CraftingMenu.gd
extends Control
class_name CraftingMenu

@export var recipe_button_scene: PackedScene = preload("res://Base/Scenes/recipe_button.tscn")

@onready var recipe_container := $Panel/VBoxContainer
@onready var queue_container  := $Panel/HBoxContainer/Queue
@onready var info_label       := $VBoxContainer/InfoLabel
@onready var confirm_button   := $Panel/HBoxContainer/ConfirmButton
@onready var close_button     := $Panel/CloseButton
@onready var timer            := $Panel/Timer

var current_recipe: ItemRecipe = null
var queue: Array[ItemRecipe]   = []
var recipes: Array[ItemRecipe] = []

func _ready() -> void:
	hide()
	confirm_button.pressed.connect(_on_confirm_pressed)
	close_button.pressed.connect(self.hide)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func open(recipes_list: Array[ItemRecipe]) -> void:
	recipes = recipes_list
	# Очищаем старые кнопки
	for child in recipe_container.get_children():
		child.queue_free()
	_update_queue_display()
	current_recipe = null
	info_label.text       = "Выберите рецепт"
	confirm_button.disabled = true

	# Сначала настраиваем button, потом добавляем
	for r in recipes_list:
		var btn = recipe_button_scene.instantiate() as RecipeButton
		btn.setup(r)
		recipe_container.add_child(btn)
		btn.pressed.connect(func () -> void:
			_on_recipe_selected(r)
		)

	show()
	position = (get_viewport().get_visible_rect().size - size) * 0.5

func _on_recipe_selected(r: ItemRecipe) -> void:
	current_recipe = r
	var name_out = r.output.size() > 0 and (r.output[0]["Item"] as Item).name or ""
	info_label.text       = "%s\nДлительность: %ss" % [name_out, r.duration]
	confirm_button.disabled = not ResourceManager.can_afford(r.input)

func _on_confirm_pressed() -> void:
	if not current_recipe:
		return
	ResourceManager.spend(current_recipe.input)
	queue.append(current_recipe)
	_update_queue_display()
	if timer.is_stopped():
		timer.start(current_recipe.duration)

func _on_timer_timeout() -> void:
	if queue.is_empty():
		return
	var finished = queue.pop_front()
	for out in finished.output:
		var item   = out["Item"] as Item
		var amount = out.get("amount", 1)
		ResourceManager.add_resource(item.name.to_lower(), amount)
	_update_queue_display()
	if not queue.is_empty():
		timer.start(queue[0].duration)

func _update_queue_display() -> void:
	# 1) Убираем всё старое
	for child in queue_container.get_children():
		child.queue_free()

	# 2) Задаём отступы между элементами (как separation в Godot 3)
	queue_container.add_theme_constant_override("separation", 8)

	# 3) Для каждого рецепта в очереди рисуем TextureRect
	for recipe in queue:
		var item: Item = null
		if recipe.output.size() > 0 and recipe.output[0].has("Item"):
			item = recipe.output[0]["Item"] as Item

		if not item:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(32,32)
			queue_container.add_child(spacer)
			continue

		# выбираем анимацию точно так же, как в RecipeButton
		var frames = item.spritesheet
		var anims  = frames.get_animation_names()
		var base   = item.name.strip_edges().to_lower().replace(" ", "_")
		var chosen = ""
		if base + "_icon"     in anims:
			chosen = base + "_icon"
		elif base + "_ui_icon" in anims:
			chosen = base + "_ui_icon"
		elif "default_icon"   in anims:
			chosen = "default_icon"
		elif anims.size() > 0:
			chosen = anims[0]

		# первый кадр выбранной анимации
		var tex: Texture2D = null
		if chosen != "":
			tex = frames.get_frame_texture(chosen, 0)

		var icon = TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(32,32)
		icon.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		queue_container.add_child(icon)
