extends Control

@onready var recipe_list = $LeftPanel/RecipeList
@onready var icon_preview = $RightPanel/IconPreview
@onready var title_label = $RightPanel/TitleLabel
@onready var description_label = $RightPanel/Description
@onready var work_info_label = $RightPanel/WorkInfo
@onready var cost_info_label = $RightPanel/CostInfo
@onready var order_button = $RightPanel/OrderButton
@onready var progress_indicator = $RightPanel/ProgressIndicator

var current_station: CraftingStation = null
var selected_recipe: ItemRecipe = null

func open(station: CraftingStation):
	current_station = station
	_fill_recipe_list()
	_clear_right_panel()
	visible = true

func _fill_recipe_list():
	recipe_list.clear() # зависит от типа, например если это ItemList
	for recipe in current_station.recipes:
		var display_name = recipe.name
		var can_afford = ResourceManager.can_afford(recipe.input)
		recipe_list.add_item(display_name)
		recipe_list.set_item_metadata(recipe_list.item_count - 1, recipe)
		if not can_afford:
			recipe_list.set_item_custom_fg_color(recipe_list.item_count - 1, Color(1, 0.3, 0.3))

func _clear_right_panel():
	title_label.text = ""
	description_label.text = ""
	icon_preview.visible = false
	work_info_label.text = ""
	cost_info_label.text = ""
	order_button.disabled = true
	progress_indicator.visible = false

func _on_RecipeList_item_selected(index):
	var recipe: ItemRecipe = recipe_list.get_item_metadata(index)
	if recipe:
		_show_recipe(recipe)

func _show_recipe(recipe: ItemRecipe):
	selected_recipe = recipe

	title_label.text = recipe.name
	description_label.text = recipe.description
	work_info_label.text = "⛏ %s мин" % recipe.craft_time
	cost_info_label.text = _format_cost(recipe.input)

	var anim = recipe.get_animation("ui")
	if anim != "":
		icon_preview.sprite_frames = recipe.spritesheet
		icon_preview.play(anim)
		icon_preview.visible = true
	else:
		icon_preview.visible = false

	order_button.disabled = not ResourceManager.can_afford(recipe.input)

func _on_OrderButton_pressed():
	if selected_recipe and current_station:
		current_station.add_to_queue(selected_recipe)
		# можно обновить список слотов, прогресс и т.п.
		_fill_recipe_list()
		_show_recipe(selected_recipe)

func _format_cost(cost_array: Array) -> String:
	var parts = []
	for cost in cost_array:
		var res: Item = cost["resource"]
		var amount = cost["amount"]
		parts.append("%s: %d" % [res.name, amount])
	return ", ".join(parts)
