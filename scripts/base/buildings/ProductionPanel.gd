extends Control

const RecipeButtonScene = preload("res://scenes/base/buildings/RecipeButton.tscn")
const QueueSlotScene = preload("res://scenes/base/buildings/QueueSlot.tscn")

@export var recipes: Array[Resource]
@export var max_queue: int = 3

@onready var button_container = $ButtonContainer
@onready var queue_container = $QueueContainer
@onready var timer = $Timer
@onready var status_label = $StatusLabel
@onready var confirm_dialog = $ConfirmDialog
@onready var info_label = $ConfirmDialog/InfoLabel

var queue := []
var queue_slots := []
var recipe_pending: Recipe = null

func _ready():
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	confirm_dialog.confirmed.connect(_on_confirmed)
	confirm_dialog.canceled.connect(_on_canceled)

	# Создаём кнопки рецептов
	for recipe in recipes:
		var btn = RecipeButtonScene.instantiate()
		btn.setup(recipe)
		button_container.add_child(btn)
		btn.pressed.connect(func(): _on_recipe_button_pressed(btn))

	# Создаём слоты очереди (3 шт.)
	for i in range(max_queue):
		var slot = QueueSlotScene.instantiate()
		#slot.set_empty()
		queue_container.add_child(slot)
		queue_slots.append(slot)

	_update_queue_ui()

func _on_recipe_button_pressed(btn):
	
	
	var recipe = btn.recipe
	# Если очередь заполнена
	if queue.size() >= max_queue:
		status_label.text = "Очередь заполнена!"
		return
		
	if get_busy_slots_count() >= max_queue:
		status_label.text = "Очередь заполнена!"
		return
	# Проверяем ресурсы и показываем диалог
	recipe_pending = recipe
	info_label.text = (
		"Рецепт: %s\n\nНужно:\n%s\nПолучишь:\n%s\nВремя: %.1f сек." %
		[recipe.name,
		 _dict_to_string(recipe.input),
		 _dict_to_string(recipe.output),
		 recipe.duration]
	)
	confirm_dialog.popup_centered()
	

func _on_confirmed():
	
	if not recipe_pending:
		return
	if ResourceManager.can_afford(recipe_pending.input):
		ResourceManager.spend(recipe_pending.input)
		queue.append(recipe_pending)
		_update_queue_ui()
		status_label.text = "Добавлено в очередь: %s" % recipe_pending.name
		# Если в очереди только что появился первый элемент — стартуем таймер
		if queue.size() == 1 and timer.is_stopped():
			timer.start(recipe_pending.duration)
	else:
		status_label.text = "Не хватает ресурсов!"
	recipe_pending = null
	

func _on_canceled():
	status_label.text = "Крафт отменён."
	recipe_pending = null

func _on_timer_timeout():
	if queue.is_empty():
		return
	var recipe = queue.pop_front()
	# Находим первый свободный слот:
	for slot in queue_slots:
		if slot.finished_recipe == null and not slot.is_ready:
			slot.show_finished(recipe)
			break
	status_label.text = "Готово: %s!" % recipe.name
	# Запускаем следующий крафт
	if not queue.is_empty():
		timer.start(queue[0].duration)
	# НЕ вызывать здесь _update_queue_ui()!



func _update_queue_ui():
	# Обновить визуально 3 слота очереди (НЕ очищать готовые!)
	for i in range(max_queue):
		if i < queue.size():
			# Слот не готов, просто показываем рецепт из очереди
			if not queue_slots[i].is_ready:
				queue_slots[i].set_recipe(queue[i])
		else:
			# Только если слот не готов, очищаем его
			if not queue_slots[i].is_ready:
				queue_slots[i].set_empty()


func _dict_to_string(dict: Dictionary) -> String:
	var s = ""
	for k in dict.keys():
		s += "%s: %d\n" % [str(k), dict[k]]
	return s.strip_edges()
	
func _on_recipe_finished(slot_idx: int, recipe: Recipe):
		queue_slots[slot_idx].show_finished(recipe)  # slot_idx - индекс слота, куда положить результат
	# Не добавляем в ResourceManager автоматически!
func get_busy_slots_count() -> int:
	var busy = 0
	for slot in queue_slots:
		if not slot.is_empty(): # если слот не пустой (в процессе или готово)
			busy += 1
	return busy
	
