extends Control

@onready var name_label: Label = $NameLabel
@onready var icon: TextureRect = $Icon

var finished_recipe: Recipe = null   # Здесь хранится "готовый" рецепт
var is_ready: bool = false           # Флаг "готово к выдаче"

func set_recipe(recipe):
	icon.texture = recipe.icon
	name_label.text = recipe.name
	finished_recipe = null
	is_ready = false

func show_finished(recipe):
	icon.texture = recipe.icon
	name_label.text = recipe.name + " (готово!)"
	finished_recipe = recipe
	is_ready = true

func set_empty():
	icon.texture = null
	name_label.text = ""
	finished_recipe = null
	is_ready = false

func _gui_input(event):
	if is_ready and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for k in finished_recipe.output.keys():
			ResourceManager.add_resource(k, finished_recipe.output[k])
		set_empty()
		get_parent().get_parent()._update_queue_ui() # или свой путь до основного UI-скрипта
		
func is_empty() -> bool:
	return not is_ready and finished_recipe == null and icon.texture == null
