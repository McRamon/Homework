# res://Base/Scenes/recipe_button.gd
extends Button
class_name RecipeButton

var recipe_data: ItemRecipe

@onready var icon_sprite  : AnimatedSprite2D = $VBoxContainer/Icon
@onready var name_label   : Label            = $VBoxContainer/NameLabel
@onready var amount_label : Label            = $VBoxContainer/AmountLabel

func setup(r: ItemRecipe) -> void:
	recipe_data = r

	# Разбираем первый словарь output[0], ищем Item и число
	var item_res: Item = null
	var amt     : int  = 0
	if r.output.size() > 0:
		var d := r.output[0]
		for v in d.values():
			if v is Item:
				item_res = v
			elif typeof(v) == TYPE_INT:
				amt = v

	if not item_res:
		push_warning("RecipeButton: не найден Item в output[0]")
		return

	# Заполняем поля
	name_label.text   = item_res.name
	icon_sprite.sprite_frames = item_res.spritesheet
	icon_sprite.play(item_res.get_animation("ui"))
	icon_sprite.visible = true

	amount_label.text    = str(amt)
	amount_label.visible = true
