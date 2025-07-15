extends Area2D

signal build_completed
signal move_requested(building: Area2D)

var origin_scene: PackedScene

@export var footprint: Vector2i = Vector2i(1, 1)
@export var build_time: float = 3.0
@export var cost: Dictionary = {}

@onready var countdown_label: Label = $CountdownLabel
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var build_timer: Timer = $BuildTimer
@onready var long_press_timer: Timer = $LongPressTimer
@onready var info_menu: PopupPanel = $InfoMenu

var _time_left: float = 0.0
var _in_progress: bool = false

func _ready():
	build_timer.one_shot = true
	build_timer.wait_time = build_time
	build_timer.timeout.connect(_on_build_complete)
	long_press_timer.wait_time = 2.0
	long_press_timer.one_shot = true
	long_press_timer.timeout.connect(_on_long_press)

	countdown_label.visible = false
	collision_shape.disabled = false
	input_pickable = true

func get_footprint() -> Vector2i:
	return footprint

func start_build():
	modulate = Color(1, 1, 1, 0.5)
	collision_shape.disabled = true
	countdown_label.visible = true
	_time_left = build_time
	_in_progress = true
	set_process(true)
	build_timer.start()

func _process(delta):
	if not _in_progress:
		return
	_time_left = max(_time_left - delta, 0)
	_update_countdown()

func _update_countdown():
	var ts = int(ceil(_time_left))
	var h = ts / 3600
	var m = (ts / 60) % 60
	var s = ts % 60
	countdown_label.text = "%02d:%02d:%02d" % [h, m, s]

func _on_build_complete():
	modulate = Color(1, 1, 1, 1)
	collision_shape.disabled = false
	countdown_label.visible = false
	_in_progress = false
	set_process(false)
	var producer = get_node_or_null("Production")
	if producer and producer.has_method("start_production"):
		producer.start_production()
		print("✅ Производство запущено!")
	#else:
		#print("❌ Production не найден!")
	emit_signal("build_completed")

func _input_event(viewport, event: InputEvent, shape_idx: int):
	if _in_progress:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			long_press_timer.start()
		else:
			if long_press_timer.time_left > 0:
				long_press_timer.stop()
				_open_info_menu()

func _on_long_press():
	emit_signal("move_requested", self)

func _open_info_menu():
	info_menu.popup_centered()

func _on_move_pressed():
	info_menu.hide()
	emit_signal("move_requested", self)
