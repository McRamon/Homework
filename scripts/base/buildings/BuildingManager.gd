extends Node2D

@export var house_scene: PackedScene
@export var barn_scene: PackedScene
@export var mill_scene: PackedScene

var _mode_scene: PackedScene
var _mode_footprint: Vector2i = Vector2i(1, 1)
var _mode_cost: Dictionary = {}
var _placing_mode: String = "" # "build" или "move"

var _ghost: Sprite2D
var _placing := false

var _pending_cell
var _pending_snap

var _occupied: Dictionary = {}  # Vector2i → bool

var _relocate_building: Area2D = null
var _relocate_old_cell: Vector2i = Vector2i.ZERO

@onready var place_dialog: ConfirmationDialog = $"../CanvasLayer/PlaceDialog"
@onready var move_dialog: ConfirmationDialog = $"../CanvasLayer/MoveDialog"
@onready var buildings_root: Node = $"../Buildings"

func _ready() -> void:
	_ghost = Sprite2D.new()
	add_child(_ghost)
	_ghost.visible = false
	set_process(true)
	place_dialog.confirmed.connect(_on_place_confirmed)
	place_dialog.canceled.connect(_cancel_placing)
	move_dialog.confirmed.connect(_on_move_confirmed)
	move_dialog.canceled.connect(_on_move_cancelled)

func request_build_house():
	_start_placing(house_scene)
func request_build_barn():
	_start_placing(barn_scene)
func request_build_mill():
	_start_placing(mill_scene)

func _start_placing(scene: PackedScene) -> void:
	_mode_scene = scene
	var tmp = scene.instantiate() as Area2D
	if tmp.has_method("get_footprint"):
		_mode_footprint = tmp.get_footprint()
	else:
		_mode_footprint = Vector2i(1, 1)
	_mode_cost = tmp.cost
	var sprite_node = tmp.get_node_or_null("Sprite2D")
	if sprite_node and sprite_node.texture:
		_ghost.texture = sprite_node.texture
	else:
		print("Sprite2D не найден или нет текстуры!")
	tmp.queue_free()
	_ghost.modulate = Color(0, 1, 0, 0.5)
	_ghost.visible = true
	_placing = true
	_placing_mode = "build"

func _process(_delta: float) -> void:
	if not _placing:
		return
	if _placing_mode == "build":
		_update_placing_logic()
	elif _placing_mode == "move":
		_update_relocate_logic()

func _update_placing_logic():
	var mp = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 32), int(mp.y / 32))
	var snap = Vector2(cell.x * 32, cell.y * 32)
	var can_place = is_area_free(cell, _mode_footprint)
	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center
	_ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	if can_place and Input.is_action_just_pressed("mouse_left"):
		_pending_cell = cell
		_pending_snap = snap
		place_dialog.popup_centered()
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_placing()

func _on_place_confirmed():
	var rm = ResourceManager
	if rm.can_afford(_mode_cost):
		rm.spend(_mode_cost)
		_place_building(_pending_cell, _pending_snap)
	else:
		print("Недостаточно ресурсов:", _mode_cost)
	_cancel_placing()

func _place_building(cell: Vector2i, snap: Vector2) -> void:
	if not is_area_free(cell, _mode_footprint):
		print("Ошибка: место занято!")
		return
	# 1. Помечаем клетки как занятые
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			_occupied[cell + Vector2i(dx, dy)] = true
	# 2. Создаём и размещаем здание
	var bld = _mode_scene.instantiate() as Area2D
	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	bld.global_position = snap + center
	buildings_root.add_child(bld)
	bld.connect("build_completed", Callable(self, "_on_build_completed"))
	bld.connect("move_requested", Callable(self, "_on_move_requested"))
	bld.origin_scene = _mode_scene
	# СТАРТУЕМ СТРОИТЕЛЬСТВО:
	bld.start_build() # <--- ВОТ ЭТО!
	_ghost.visible = false
	_placing = false


func _cancel_placing() -> void:
	_ghost.visible = false
	_placing = false

# --- Перемещение зданий ---
func _on_move_requested(bld: Area2D):
	_relocate_building = bld
	var fp = bld.get_footprint()
	var pos = bld.global_position - Vector2(fp.x * 16, fp.y * 16)
	_relocate_old_cell = Vector2i(int(pos.x / 32), int(pos.y / 32))
	_mode_footprint = fp
	var sprite_node = bld.get_node_or_null("Sprite2D")
	if sprite_node and sprite_node.texture:
		_ghost.texture = sprite_node.texture
	_ghost.visible = true
	_placing = true
	_placing_mode = "move"
	bld.visible = false

func _update_relocate_logic():
	var mp = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 32), int(mp.y / 32))
	var snap = Vector2(cell.x * 32, cell.y * 32)
	var can_place = is_area_free(cell, _mode_footprint)
	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center
	_ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	if can_place and Input.is_action_just_pressed("mouse_left"):
		_pending_cell = cell
		_pending_snap = snap
		move_dialog.popup_centered()
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_move()

func _on_move_confirmed():
	var fp = _mode_footprint
	# Освобождаем старое место
	for dx in range(fp.x):
		for dy in range(fp.y):
			_occupied[_relocate_old_cell + Vector2i(dx, dy)] = false
	# Занимаем новое
	for dx in range(fp.x):
		for dy in range(fp.y):
			_occupied[_pending_cell + Vector2i(dx, dy)] = true
	var center = Vector2(32, 32) * 0.5 * Vector2(fp.x, fp.y)
	_relocate_building.global_position = _pending_snap + center
	_relocate_building.visible = true
	_relocate_building = null
	_placing = false
	_ghost.visible = false
	_placing_mode = ""

func _on_move_cancelled():
	var fp = _mode_footprint
	var snap = Vector2(_relocate_old_cell) * 32
	var center = Vector2(32, 32) * 0.5 * Vector2(fp.x, fp.y)
	_relocate_building.global_position = snap + center
	_relocate_building.visible = true
	_relocate_building = null
	_placing = false
	_ghost.visible = false
	_placing_mode = ""

func _cancel_move():
	if _relocate_building:
		_relocate_building.visible = true
		_relocate_building = null
	_placing = false
	_ghost.visible = false
	_placing_mode = ""

func _on_build_completed():
	pass # обработка завершения строительства, если нужна

func is_area_free(cell: Vector2i, footprint: Vector2i) -> bool:
	for dx in range(footprint.x):
		for dy in range(footprint.y):
			var pos = cell + Vector2i(dx, dy)
			if _occupied.get(pos, false):
				return false
	return true
