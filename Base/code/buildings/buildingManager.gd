extends Node2D

enum Mode { NONE, BUILD, MOVE }

signal building_placed(building: Area2D)
signal building_moved(building: Area2D, old_cell: Vector2i)

@export var tile_size: int = 32

var mode: Mode = Mode.NONE
var ghost: Sprite2D
var current_data: BuildingData

var occupied: Dictionary = {} # Vector2i → Area2D
var pending_cell: Vector2i
var pending_snap: Vector2

var relocate_building: Area2D = null
var relocate_old_cell: Vector2i = Vector2i.ZERO

@onready var buildings_root: Node = $"../Buildings"
@onready var ui_manager = $"../CanvasLayer/BuildUIManager"

func _ready():
	ghost = Sprite2D.new()
	add_child(ghost)
	ghost.visible = false
	ui_manager.confirmed.connect(_on_ui_confirmed)
	ui_manager.cancelled.connect(_on_ui_cancelled)

func _on_ConfirmDialog_confirmed():
	print("🔔 Сигнал confirmed отправлен")
	emit_signal("confirmed")

func _on_ConfirmDialog_canceled():
	print("🔔 Сигнал cancelled отправлен")
	emit_signal("cancelled")





# 🔹 Запуск постройки
func request_build(data: BuildingData):
	current_data = data
	ghost.texture = data.icon_preview
	ghost.visible = true
	mode = Mode.BUILD

func _process(_delta):
	match mode:
		Mode.BUILD: _process_build()
		Mode.MOVE: _process_move()

# 🔹 Логика постройки
func _process_build():
	var cell = _mouse_to_cell()
	var snap = cell_to_snap(cell)
	var can_place = is_area_free(cell, current_data.footprint)

	ghost.global_position = snap + footprint_center(current_data.footprint)
	ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	if can_place and Input.is_action_just_pressed("mouse_left"):
		pending_cell = cell
		pending_snap = snap
		ui_manager.show_confirm_dialog("Построить %s?" % current_data.name)
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel()

func _on_ui_confirmed():
	if mode == Mode.BUILD:
		_place_building(pending_cell, pending_snap) # <--- создаёт реальное здание
	elif mode == Mode.MOVE:
		_finalize_move()
	_cancel() # <--- скрывает ghost
	


func _on_ui_cancelled():
	if mode == Mode.MOVE:
		_cancel_move()
	else:
		_cancel()

func _place_building(cell: Vector2i, snap: Vector2):
	print("✅ Спавним здание:", current_data.name)
	# Помечаем клетки как занятые
	for dx in range(current_data.footprint.x):
		for dy in range(current_data.footprint.y):
			occupied[cell + Vector2i(dx, dy)] = true

	# Создаём здание
	var bld = current_data.scene.instantiate() as Area2D
	bld.global_position = snap + footprint_center(current_data.footprint)

	# ✅ Меняем картинку на built_texture
	var sprite_node = bld.get_node_or_null("Sprite2D")
	if sprite_node and current_data.built_texture:
		sprite_node.texture = current_data.built_texture

	buildings_root.add_child(bld)
	bld.connect("move_requested", Callable(self, "_on_move_requested"))

	# Запускаем процесс строительства
	if bld.has_method("start_build"):
		bld.start_build(current_data.build_time)

	emit_signal("building_placed", bld)


func _cancel():
	ghost.visible = false
	mode = Mode.NONE

# 🔹 Перемещение зданий
func _on_move_requested(bld: Area2D):
	relocate_building = bld
	var fp = bld.get_footprint()
	var pos = bld.global_position - footprint_center(fp)
	relocate_old_cell = Vector2i(int(pos.x / tile_size), int(pos.y / tile_size))

	var sprite_node = bld.get_node_or_null("Sprite2D")
	if sprite_node and sprite_node.texture:
		ghost.texture = sprite_node.texture

	ghost.visible = true
	bld.visible = false
	mode = Mode.MOVE

func _process_move():
	var cell = _mouse_to_cell()
	var snap = cell_to_snap(cell)
	var fp = relocate_building.get_footprint()
	var can_place = is_area_free(cell, fp)

	ghost.global_position = snap + footprint_center(fp)
	ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	if can_place and Input.is_action_just_pressed("mouse_left"):
		pending_cell = cell
		pending_snap = snap
		ui_manager.show_confirm_dialog("Переместить здание?")
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_move()

func _finalize_move():
	var fp = relocate_building.get_footprint()
	for dx in range(fp.x):
		for dy in range(fp.y):
			occupied[relocate_old_cell + Vector2i(dx, dy)] = null
	for dx in range(fp.x):
		for dy in range(fp.y):
			occupied[pending_cell + Vector2i(dx, dy)] = relocate_building

	relocate_building.global_position = pending_snap + footprint_center(fp)
	relocate_building.visible = true
	emit_signal("building_moved", relocate_building, relocate_old_cell)
	relocate_building = null

func _cancel_move():
	if relocate_building:
		relocate_building.visible = true
		relocate_building = null
	_cancel()

# 🔹 Вспомогательные функции
func _mouse_to_cell() -> Vector2i:
	var mp = get_viewport().get_mouse_position()
	return Vector2i(int(mp.x / tile_size), int(mp.y / tile_size))

func cell_to_snap(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func footprint_center(fp: Vector2i) -> Vector2:
	return Vector2(tile_size, tile_size) * 0.5 * Vector2(fp.x, fp.y)

func is_area_free(cell: Vector2i, fp: Vector2i) -> bool:
	for dx in range(fp.x):
		for dy in range(fp.y):
			var pos = cell + Vector2i(dx, dy)
			if occupied.has(pos) and occupied[pos] != null:
				return false
	return true
