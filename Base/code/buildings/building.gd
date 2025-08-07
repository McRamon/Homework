# Building.gd
extends Node2D

const CraftingMenuScene : PackedScene = preload("res://Base/Scenes/crafting_menu.tscn")
@export var recipes: Array[ItemRecipe] = []

var _built := false
var _crafting_menu: CraftingMenu = null

func _ready() -> void:
	$Area2D.monitorable    = false
	$Area2D.input_pickable = false
	$Area2D.connect("input_event", Callable(self, "_on_area_input"))

func built_ready() -> void:
	_built = true
	$Area2D.monitorable    = true
	$Area2D.input_pickable = true

func _on_area_input(viewport, event: InputEvent, shape_idx: int) -> void:
	# 1) блокируем меню крафта, если мы в режиме постройки
	var bm = get_tree().root.get_node("BuildingManager") as Node
	if bm.in_build_mode:
		return

	# 2) дальше только если здание уже построено
	if not _built:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _crafting_menu == null:
			_crafting_menu = CraftingMenuScene.instantiate() as CraftingMenu
			var canvas = get_tree().current_scene.get_node("CanvasLayer") as CanvasLayer
			canvas.add_child(_crafting_menu)
		_crafting_menu.open(recipes)
