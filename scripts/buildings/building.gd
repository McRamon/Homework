extends Area2D

signal build_completed
signal move_requested(building: Area2D)

# Храним ссылку на оригинальную сцену для повторного размещения
var origin_scene: PackedScene

@export var footprint: Vector2i = Vector2i(1, 1)
@export var build_time: float = 3.0
@export var cost: Dictionary = {"wood": 10, "stone": 5}

@onready var cost_label: Label             = $CostLabel
@onready var countdown_label: Label        = $CountdownLabel
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var build_timer: Timer            = $BuildTimer
@onready var long_press_timer: Timer       = $LongPressTimer
@onready var info_menu: PopupPanel         = $InfoMenu
#@onready var move_button: Button           = $InfoMenu/MoveButton

var _time_left: float = 0.0
var _in_progress: bool = false

func _ready() -> void:
	build_timer.one_shot = true
	build_timer.wait_time = build_time
	build_timer.connect("timeout", Callable(self, "_on_build_complete"))

	long_press_timer.wait_time = 2.0
	long_press_timer.one_shot = true
	long_press_timer.connect("timeout", Callable(self, "_on_long_press"))

	#move_button.connect("pressed", Callable(self, "_on_move_pressed"))

	_update_cost_label()
	cost_label.visible = true
	countdown_label.visible = false
	collision_shape.disabled = false
	input_pickable = true

func get_footprint() -> Vector2i:
	return footprint

func start_build() -> void:
	modulate = Color(1, 1, 1, 0.5)
	collision_shape.disabled = true
	cost_label.visible = false
	countdown_label.visible = true

	_time_left = build_time
	_in_progress = true
	set_process(true)
	build_timer.start()

func _process(delta: float) -> void:
	if not _in_progress:
		return
	_time_left = max(_time_left - delta, 0)
	_update_countdown()
	if _time_left <= 0:
		_on_build_complete()

func _update_countdown() -> void:
	var ts = int(ceil(_time_left))
	var h = ts / 3600
	var m = (ts / 60) % 60
	var s = ts % 60
	countdown_label.text = "%02d:%02d:%02d" % [h, m, s]

func _on_build_complete() -> void:
	modulate = Color(1, 1, 1, 1)
	collision_shape.disabled = false
	countdown_label.visible = false
	_in_progress = false
	set_process(false)
	emit_signal("build_completed")

func _update_cost_label() -> void:
	var text := ""
	for r in cost.keys():
		text += "%s: %d\n" % [r.capitalize(), cost[r]]
	if text.ends_with("\n"):
		text = text.substr(0, text.length() - 1)
	cost_label.text = text

func _input_event(viewport: Object, event: InputEvent, shape_idx: int) -> void:
	if _in_progress:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			long_press_timer.start()
		else:
			if long_press_timer.time_left > 0:
				long_press_timer.stop()
				_open_info_menu()

func _on_long_press() -> void:
	emit_signal("move_requested", self)

func _open_info_menu() -> void:
	info_menu.popup_centered()

func _on_move_pressed() -> void:
	info_menu.hide()
	emit_signal("move_requested", self)
