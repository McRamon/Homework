# res://Base/Code/buildings/CraftingMenu.gd
extends Control
class_name CraftingMenu

@export var recipe_button_scene: PackedScene = preload("res://Base/Scenes/recipe_button.tscn")

@onready var recipe_container := $Panel/VBoxContainer
@onready var queue_container  := $Panel/HBoxContainer/Queue
@onready var info_label       := $Panel/InfoLabel
@onready var confirm_button   := $Panel/HBoxContainer/ConfirmButton
@onready var close_button     := $Panel/CloseButton
@onready var timer            := $Panel/Timer

var current_recipe: ItemRecipe = null
var queue: Array[ItemRecipe]  = []
var recipes: Array[ItemRecipe] = []

func _ready() -> void:
	hide()
	confirm_button.pressed.connect(_on_confirm_pressed)
	close_button.pressed.connect(self.hide)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func open(recipes_list: Array[ItemRecipe]) -> void:
	# Сохраняем список (если нужно)
	recipes = recipes_list

	# Очищаем старые кнопки
	for child in recipe_container.get_children():
		child.queue_free()
	# Очищаем очередь

	_update_queue_display()

	# Сбрасываем правую панель
	current_recipe = null
	info_label.text = "Выберите рецепт"
	confirm_button.disabled = true

	# Создаём кнопку на каждый рецепт
	for r in recipes_list:
		var btn = recipe_button_scene.instantiate() as RecipeButton
		recipe_container.add_child(btn)  # Сначала в дерево
		btn.setup(r)                     # Потом настраиваем
		btn.pressed.connect(func () -> void:
			_on_recipe_selected(r)
		)

	# Показываем меню и поднимаем его наверх
	show()

	# Центрируем по экрану
	position = (get_viewport().get_visible_rect().size - size) * 0.5


func _on_recipe_selected(r: ItemRecipe) -> void:
	current_recipe = r
	# название и длительность
	var name_out = r.output.size() > 0 and (r.output[0]["Item"] as Item).name or ""
	info_label.text = "%s\nДлительность: %ss" % [name_out, r.duration]
	# проверяем ресурсы
	confirm_button.disabled = not ResourceManager.can_afford(r.input)

func _on_confirm_pressed() -> void:
	if not current_recipe:
		return
	# списываем ресурсы
	ResourceManager.spend(current_recipe.input)
	# добавляем в очередь и стартуем таймер, если он свободен
	queue.append(current_recipe)
	_update_queue_display()
	if not timer.is_stopped():
		return
	timer.start(current_recipe.duration)

func _on_timer_timeout() -> void:
	if queue.is_empty():
		return
	var finished = queue.pop_front()
	# выдаём результат
	for out in finished.output:
		ResourceManager.add_resource((out["Item"] as Item).name.to_lower(), out["amount"])
	_update_queue_display()
	if not queue.is_empty():
		timer.start(queue[0].duration)

func _update_queue_display() -> void:
	# Очищаем предыдущие Label
	for child in queue_container.get_children():
		child.queue_free()

	# Рисуем текущую очередь
	for recipe in queue:
		var lbl := Label.new()
		# Получаем имя выходного Item или “?” если его нет
		var name_out : String = ""
		if recipe.output.size() > 0 and recipe.output[0].has("Item"):
			name_out = (recipe.output[0]["Item"] as Item).name
		else:
			name_out = "?"
		lbl.text = name_out
		queue_container.add_child(lbl)
