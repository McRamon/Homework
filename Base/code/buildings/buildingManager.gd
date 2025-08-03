extends Node2D

var current_data: BuildingData = null
@export var tile_size := 32   # размер сетки

func request_build(data: BuildingData):
	current_data = data
	print("▶ Выбрано здание:", data.name)

func _unhandled_input(event):
	if current_data and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos = get_global_mouse_position()
		var snap = pos.snapped(Vector2(tile_size, tile_size))
		_place_building(snap)

func _place_building(snap: Vector2):
	if not current_data:
		return

	print("🔍 Проверка ресурсов для:", current_data.name)
	if not ResourceManager.can_afford(current_data.build_requirements):
		print("❌ Недостаточно ресурсов для:", current_data.name)
		return

	# списываем ресурсы
	ResourceManager.spend(current_data.build_requirements)
	print("✅ Ресурсы списаны. Остаток:", ResourceManager.resources)

	# создаём здание
	var bld = current_data.scene.instantiate()
	bld.global_position = snap
	add_child(bld)
	if bld.has_method("start_build"):
		bld.start_build(current_data.build_time)

	print("🏗️ Здание построено:", current_data.name)
	current_data = null
