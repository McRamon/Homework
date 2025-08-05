extends Node2D

@export var recipes: Array[ItemRecipe] = []
var _built := false

func _ready() -> void:
	# до готовности здание не реагирует на клики
	$Area2D.monitoring  = false
	$Area2D.monitorable = false
	$Area2D.connect("input_event", Callable(self, "_on_area_input"))

# этот метод вызывается извне, когда строительство завершилось
func built_ready() -> void:
	_built = true
	$Area2D.monitoring  = true
	$Area2D.monitorable = true

func _on_area_input(viewport, event: InputEvent, shape_idx: int) -> void:
	# пока не построили — сразу выходим
	if not _built:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cm = get_tree().current_scene.get_node("CanvasLayer/CraftingMenu") as CraftingMenu
		cm.open(recipes)
