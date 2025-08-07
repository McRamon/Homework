# res://Base/Scenes/recipe_button.gd
extends Button
class_name RecipeButton

# Храним текущий рецепт (если пригодится позже)
var recipe_data: ItemRecipe

# Пути к узлам внутри сцены — поправьте в инспекторе, если переименовали
@export var icon_path   : NodePath = "VBoxContainer/Icon"
@export var name_path   : NodePath = "VBoxContainer/NameLabel"
@export var amount_path : NodePath = "VBoxContainer/AmountLabel"

func setup(r: ItemRecipe) -> void:
	recipe_data = r

	# 1) Достаём узлы
	var icon_sprite  = get_node_or_null(icon_path)   as AnimatedSprite2D
	var name_label   = get_node_or_null(name_path)   as Label
	var amount_label = get_node_or_null(amount_path) as Label
	if not icon_sprite or not name_label or not amount_label:
		push_error("RecipeButton: не найден один из узлов — проверьте icon_path/name_path/amount_path")
		return

	# 2) Разбор output: Item + количество
	if r.output.is_empty():
		push_warning("RecipeButton: пустой output у рецепта")
		return
	var item_res : Item = r.output[0].get("Item")   as Item
	var amt      : int  = r.output[0].get("amount", 1)
	if not item_res:
		push_warning("RecipeButton: нет Item в output[0]")
		return

	# 3) Заполняем текстовые лейблы
	name_label.text  = item_res.name
	name_label.show()

	amount_label.text   = str(amt)
	amount_label.show()

	# 4) Подключаем SpriteFrames и ищем нужную анимацию
	var frames = item_res.spritesheet
	if not frames:
		push_warning("RecipeButton: у %s нет sprite_frames" % item_res.name)
		icon_sprite.hide()
		return
	icon_sprite.sprite_frames = frames

	var anims = frames.get_animation_names()
	var base  = item_res.name.strip_edges().to_lower().replace(" ", "_")

	# приоритет поиска:
	# 1) <base>_icon
	# 2) <base>_ui_icon
	# 3) default_icon
	# 4) первый элемент из списка anims
	var chosen = ""
	if base + "_icon"    in anims:
		chosen = base + "_icon"
	elif base + "_ui_icon" in anims:
		chosen = base + "_ui_icon"
	elif "default_icon"  in anims:
		chosen = "default_icon"
	elif anims.size() > 0:
		chosen = anims[0]

	if chosen == "":
		push_warning("RecipeButton: не нашёл ни одной анимации в %s" % anims)
		icon_sprite.hide()
		return

	icon_sprite.animation = chosen
	icon_sprite.play()
	icon_sprite.show()
