extends Node2D

@export var house_scene: PackedScene
@export var barn_scene: PackedScene
@export var mill_scene: PackedScene

var _mode_scene: PackedScene
var _mode_footprint: Vector2i = Vector2i(1, 1)
var _mode_cost: Dictionary = {}

var _ghost: Sprite2D
var _placing := false

var _pending_cell
var _pending_snap

var _occupied: Dictionary = {}  # Vector2i → bool

# перемещение
var _relocating: bool = false
var _relocate_building: Area2D = null
var _relocate_old_cell: Vector2i = Vector2i.ZERO

func _ready() -> void:
	_ghost = Sprite2D.new()
	add_child(_ghost)
	_ghost.visible = false

	# Кнопки строительства
	$CanvasLayer/HouseButton.connect("pressed", Callable(self, "_on_house_button"))
	$CanvasLayer/BarnButton.connect("pressed", Callable(self, "_on_barn_button"))
	$CanvasLayer/MillButton.connect("pressed", Callable(self, "_on_mill_button"))

	# Диалог подтверждения
	var dlg = $CanvasLayer/PlaceDialog as ConfirmationDialog
	dlg.ok_button_text = "OK"
	dlg.cancel_button_text = "Отмена"
	dlg.connect("confirmed", Callable(self, "_on_place_confirmed"))
	dlg.connect("canceled", Callable(self, "_on_place_cancelled"))

	set_process(true)

func _on_house_button() -> void:
	_start_placing(house_scene)

func _on_barn_button() -> void:
	_start_placing(barn_scene)

func _on_mill_button() -> void:
	_start_placing(mill_scene)

func _start_placing(scene: PackedScene) -> void:
	_mode_scene = scene
	var tmp = scene.instantiate() as Area2D

	if tmp.has_method("get_footprint"):
		_mode_footprint = tmp.get_footprint()
	else:
		_mode_footprint = Vector2i(1, 1)

	_mode_cost = tmp.cost
	_ghost.texture = tmp.get_node("Sprite2D").texture
	tmp.queue_free()

	_ghost.modulate = Color(0, 1, 0, 0.5)
	_ghost.visible = true
	_placing = true

func _process(_delta: float) -> void:
	_update_build_buttons()

	if not _placing:
		return

	var mp = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 32), int(mp.y / 32))
	var snap = Vector2(cell.x * 32, cell.y * 32)

	var can_place = true
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			if _occupied.has(cell + Vector2i(dx, dy)):
				can_place = false
				break
		if not can_place:
			break

	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center
	_ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	if can_place and Input.is_action_just_pressed("mouse_left"):
		_pending_cell = cell
		_pending_snap = snap
		$CanvasLayer/PlaceDialog.popup_centered()
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_placing()

func _update_build_buttons() -> void:
	var rm = ResourceManager
	_set_button_state($CanvasLayer/HouseButton, rm.can_afford(_get_cost(house_scene)))
	_set_button_state($CanvasLayer/BarnButton, rm.can_afford(_get_cost(barn_scene)))
	_set_button_state($CanvasLayer/MillButton, rm.can_afford(_get_cost(mill_scene)))

func _set_button_state(btn: Button, can_buy: bool) -> void:
	btn.disabled = not can_buy
	btn.modulate = Color(1, 1, 1, 1) if can_buy else Color(1, 1, 1, 0.5)

func _get_cost(scene: PackedScene) -> Dictionary:
	var tmp = scene.instantiate() as Area2D
	var c = tmp.cost
	tmp.queue_free()
	return c

func _on_place_confirmed() -> void:
	if _relocating:
		_place_relocated_building(_pending_cell, _pending_snap)
		return

	var rm = ResourceManager
	if rm.can_afford(_mode_cost):
		rm.spend(_mode_cost)
		_update_build_buttons()
		_place_building(_pending_cell, _pending_snap)
	else:
		print("Недостаточно ресурсов:", _mode_cost)

	_pending_cell = null
	_pending_snap = null

func _on_place_cancelled() -> void:
	if _relocating and _relocate_building != null:
		var fp = _relocate_building.get_footprint()
		for dx in range(fp.x):
			for dy in range(fp.y):
				_occupied[_relocate_old_cell + Vector2i(dx, dy)] = true

		var snap = Vector2(_relocate_old_cell) * 32
		var center = Vector2(32, 32) * 0.5 * Vector2(fp.x, fp.y)
		_relocate_building.global_position = snap + center
		_relocate_building.visible = true
		_relocate_building = null
		_relocating = false
		_ghost.visible = false
		_placing = false
	else:
		_cancel_placing()

func _place_building(cell: Vector2i, snap: Vector2) -> void:
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			_occupied[cell + Vector2i(dx, dy)] = true

	var bld = _mode_scene.instantiate() as Area2D
	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	bld.global_position = snap + center
	$Buildings.add_child(bld)

	bld.origin_scene = _mode_scene
	bld.start_build()
	bld.connect("build_completed", Callable(self, "_on_build_completed"))
	bld.connect("move_requested", Callable(self, "_on_move_requested"))

	_ghost.visible = false
	_placing = false

func _place_relocated_building(cell: Vector2i, snap: Vector2) -> void:
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			_occupied[cell + Vector2i(dx, dy)] = true

	var center = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_relocate_building.global_position = snap + center
	_relocate_building.visible = true

	_relocate_building = null
	_relocating = false
	_ghost.visible = false
	_placing = false

func _cancel_placing() -> void:
	_ghost.visible = false
	_placing = false

func _on_move_requested(bld: Area2D) -> void:
	var fp = bld.get_footprint()
	var pos = bld.global_position - Vector2(fp.x * 16, fp.y * 16)
	var cell = Vector2i(int(pos.x / 32), int(pos.y / 32))

	for dx in range(fp.x):
		for dy in range(fp.y):
			_occupied.erase(cell + Vector2i(dx, dy))

	bld.visible = false
	_relocate_building = bld
	_relocate_old_cell = cell
	_mode_scene = bld.origin_scene
	_mode_cost = {}
	_mode_footprint = fp
	_ghost.texture = bld.get_node("Sprite2D").texture
	_ghost.visible = true
	_placing = true
	_relocating = true
