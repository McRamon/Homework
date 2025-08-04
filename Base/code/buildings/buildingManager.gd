extends Node

@onready var buildings_root = $"../Buildings"
@onready var grid_size = 32

# ✅ Ссылка на диалог подтверждения
@onready var dialog = get_tree().get_root().get_node("Base/CanvasLayer/BuildConfirmDialog")
@onready var dialog_label = dialog.get_node("Label")

var current_data: BuildingData = null
var ghost: Node2D = null
var occupied_cells: Dictionary = {}

# ✅ Таймер для окна
var confirm_timer: Timer = null
var pending_cell: Vector2i
var pending_snap: Vector2

func _ready():
	confirm_timer = Timer.new()
	confirm_timer.one_shot = true
	confirm_timer.wait_time = 5.0  # ⏱ 5 секунд на подтверждение
	confirm_timer.timeout.connect(_on_confirm_timeout)
	add_child(confirm_timer)

func request_build(data: BuildingData):
	current_data = data
	print("▶ Режим постройки:", data.name)

func _unhandled_input(event):
	if current_data == null:
		return

	if event is InputEventMouseMotion:
		_update_ghost()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_show_confirm_dialog()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_build()

func _update_ghost():
	if ghost == null:
		ghost = current_data.scene.instantiate()
		ghost.modulate = Color(1, 1, 1, 0.5)
		add_child(ghost)

	var cell = mouse_to_cell()
	var snap = cell_to_snap(cell)
	ghost.global_position = snap

	var can_place = _can_place(cell, current_data.footprint)
	ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

# ✅ Окно подтверждения при ЛКМ
func _show_confirm_dialog():
	var cell = mouse_to_cell()
	if not _can_place(cell, current_data.footprint):
		print("❌ Место занято!")
		return

	pending_cell = cell
	pending_snap = cell_to_snap(cell)

	var cost_text = ""
	for req in current_data.build_requirements:
		var res: Item = req["resource"]
		var amount = req["amount"]
		cost_text += "%s: %d\n" % [res.name, amount]

	dialog_label.text = "Построить %s?\n\nСтоимость:\n%s" % [current_data.name, cost_text]

	if dialog.confirmed.is_connected(_on_confirm_build):
		dialog.confirmed.disconnect(_on_confirm_build)
	if dialog.canceled.is_connected(_on_cancel_build):
		dialog.canceled.disconnect(_on_cancel_build)

	dialog.confirmed.connect(_on_confirm_build)
	dialog.canceled.connect(_on_cancel_build)

	dialog.popup_centered()
	confirm_timer.start()  # ⏱ запускаем таймер

func _on_confirm_build():
	confirm_timer.stop()
	_place_building(pending_cell, pending_snap)

func _on_cancel_build():
	confirm_timer.stop()
	_cancel_build()

func _on_confirm_timeout():
	print("⏱ Время подтверждения вышло")
	_cancel_build()

func _place_building(cell: Vector2i, snap: Vector2):
	if not ResourceManager.can_afford(current_data.build_requirements):
		print("❌ Недостаточно ресурсов!")
		_cancel_build()
		return

	ResourceManager.spend(current_data.build_requirements)

	var bld = current_data.scene.instantiate()
	bld.global_position = snap
	buildings_root.add_child(bld)
	bld.start_build(current_data.build_time)

	for x in range(current_data.footprint.x):
		for y in range(current_data.footprint.y):
			occupied_cells[cell + Vector2i(x, y)] = true

	print("🏗️ Построено:", current_data.name)
	_cancel_build()

func _cancel_build():
	if ghost:
		ghost.queue_free()
		ghost = null
	current_data = null

func _can_place(cell: Vector2i, fp: Vector2i) -> bool:
	for x in range(fp.x):
		for y in range(fp.y):
			if occupied_cells.has(cell + Vector2i(x, y)):
				return false
	return true

func mouse_to_cell() -> Vector2i:
	var mp = get_viewport().get_mouse_position()
	return Vector2i(floor(mp.x / grid_size), floor(mp.y / grid_size))

func cell_to_snap(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * grid_size, cell.y * grid_size)
