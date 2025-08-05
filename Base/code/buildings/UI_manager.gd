extends CanvasLayer    # или Control/Node2D — где вам удобно

@export var building_types: Array[BuildingData] = []
@export var button_scene: PackedScene = preload("res://Base/Scenes/building_button.tscn")

func _ready():
	init_build_menu()

func init_build_menu():
	var container = $BuildMenu/ButtonsContainer
	container.clear()  # на всякий случай очистим
	for data in building_types:
		var btn = button_scene.instantiate()
		# — настраиваем как в вашем примере —
		btn.get_node("NameLabel").text = data.name
		# иконка, требования, блокировка и сигнал нажатия…
		btn.connect("pressed", callable(self, "_on_build_button_pressed"), data)
		container.add_child(btn)
