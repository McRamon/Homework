extends Node

const GHOST_COLOR_VALID   = Color(0.5, 1.0, 0.5, 0.5)
const GHOST_COLOR_INVALID = Color(1.0, 0.5, 0.5, 0.5)

var map: TileMapLayer
var confirm_dialog: ConfirmationDialog

var ghost: Node2D = null
var current_data: BuildingData = null
var confirmed_pos: Vector2 = Vector2.ZERO

var construction_timer: Dictionary = {}

func _ready() -> void:
	map = get_tree().current_scene.get_node("TileMapLayer") as TileMapLayer
	confirm_dialog = get_tree().current_scene.get_node("CanvasLayer/ConfirmationDialog") as ConfirmationDialog
	if confirm_dialog and not confirm_dialog.confirmed.is_connected(_on_confirmed):
		confirm_dialog.confirmed.connect(_on_confirmed)
	set_process(false)


func enter_build_mode(data: BuildingData) -> void:
	current_data = data
	if ghost:
		ghost.queue_free()

	ghost = data.building_scene.instantiate() as Node2D
	ghost.modulate = GHOST_COLOR_INVALID
	ghost.z_index = 100
	map.add_child(ghost)

	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(_delta: float) -> void:
	if not ghost:
		return
	var mouse_pos = map.get_global_mouse_position()
	var cell = map.local_to_map(mouse_pos)
	var world_pos = map.map_to_local(cell)
	ghost.position = world_pos
	ghost.modulate = GHOST_COLOR_VALID if can_build_at(cell) else GHOST_COLOR_INVALID


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if ghost and can_build_at(map.local_to_map(ghost.position)):
					confirmed_pos = ghost.position
					confirm_dialog.dialog_text = "Построить %s здесь?".format([current_data.name])
					confirm_dialog.popup_centered()
			MOUSE_BUTTON_RIGHT:
				cancel_build_mode()
	if event.is_action_pressed("ui_cancel"):
		cancel_build_mode()


func can_build_at(cell: Vector2i) -> bool:
	var world_pos = map.map_to_local(cell)
	for child in map.get_children():
		if child is Node2D and child != ghost:
			if child.position.distance_to(world_pos) < 1.0:
				return false
	return true


func _on_confirmed() -> void:
	if not current_data:
		return

	# Инстанцируем сам building, сразу выключаем его Area2D
	var building = current_data.building_scene.instantiate() as Node2D
	building.position = confirmed_pos
	# Предполагаем, что внутри building есть Area2D
	var area = building.get_node("Area2D") as Area2D
	if area:
		area.monitoring = false

	map.add_child(building)

	# Списываем ресурсы
	var requirements := []
	for i in current_data.requirement_items.size():
		requirements.append({
			"resource": current_data.requirement_items[i],
			"amount": current_data.requirement_amounts[i],
		})
	ResourceManager.spend(requirements)

	# Запускаем таймер
	var label = building.get_node("TimeLabel") as Label
	start_construction_timer(building, label, int(current_data.build_time))
	cancel_build_mode()


func cancel_build_mode() -> void:
	if ghost:
		ghost.queue_free()
		ghost = null
	current_data = null
	set_process(false)


# === ТАЙМЕР СТРОИТЕЛЬСТВА ===

func start_construction_timer(building: Node2D, label: Label, duration: int) -> void:
	construction_timer = {
		"building": building,
		"label": label,
		"time_left": duration
	}
	label.text = format_time(duration)
	label.visible = true
	building.modulate.a = 0.5
	building.set_process(false)

	await run_timer_loop()


func run_timer_loop() -> void:
	while construction_timer and construction_timer.time_left > 0:
		await get_tree().create_timer(1.0).timeout
		construction_timer.time_left -= 1
		update_timer_label(
			construction_timer.label,
			construction_timer.building,
			construction_timer.time_left
		)

	if construction_timer:
		build_complete(construction_timer.building)
		construction_timer = {}


func update_timer_label(label: Label, building: Node2D, time_left: int) -> void:
	label.text = format_time(time_left)


func format_time(seconds: int) -> String:
	var h = seconds / 3600
	var m = (seconds % 3600) / 60
	var s = seconds % 60
	return "%02d:%02d:%02d" % [h, m, s]


func build_complete(building: Node2D) -> void:
	# возвращаем непрозрачность и включаем логику
	building.modulate.a = 1.0
	building.set_process(true)

	# снимаем блокировку клика
	if building.has_node("Area2D/CollisionShape2D"):
		var area  = building.get_node("Area2D")                     as Area2D
		var shape = building.get_node("Area2D/CollisionShape2D")    as CollisionShape2D
		area.monitoring = true
		shape.disabled  = false

	# наконец помечаем здание как построенное
	building.set("built", true)
	if building.has_method("built_ready"):
		building.call("built_ready")
