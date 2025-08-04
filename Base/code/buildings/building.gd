extends Area2D
signal build_completed

enum BuildState { CONSTRUCTING, BUILT }

@export var build_time: float = 5.0
@export var crafting_station_path: NodePath = "CraftingStation"  # ✅ путь до станции крафта внутри здания

@onready var sprite: Sprite2D = $Sprite2D
@onready var build_timer: Timer = $BuildTimer
@onready var countdown_label: Label = $CountdownLabel

var state: BuildState = BuildState.BUILT

func start_build(duration: float):
	state = BuildState.CONSTRUCTING
	sprite.modulate = Color(1, 1, 1, 0.5)

	build_timer.wait_time = duration
	build_timer.start()

	countdown_label.visible = true
	countdown_label.text = _format_time(duration)

	if not build_timer.timeout.is_connected(_finish_build):
		build_timer.timeout.connect(_finish_build, CONNECT_ONE_SHOT)

	set_process(true)

func _process(_delta):
	if state == BuildState.CONSTRUCTING:
		countdown_label.text = _format_time(build_timer.time_left)

func _finish_build():
	state = BuildState.BUILT
	sprite.modulate = Color(1, 1, 1, 1)
	countdown_label.visible = false
	set_process(false)
	emit_signal("build_completed")

# ✅ Клик по зданию
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if state == BuildState.BUILT:
			var station = get_node_or_null(crafting_station_path)
			var ui = _find_crafting_ui()
			if ui and station:
				print("📦 Открываем окно крафта для:", station.name)
				ui.open_for_station(station)
			else:
				print("⚠️ Не найден CraftingUI или CraftingStation")

# ✅ Ищем UI крафта в дереве
func _find_crafting_ui():
	return get_tree().get_root().find_child("CraftingUI", true, false)

func _format_time(t: float) -> String:
	var total_seconds = int(ceil(t))
	var h = total_seconds / 3600
	var m = (total_seconds / 60) % 60
	var s = total_seconds % 60
	return "%02d:%02d:%02d" % [h, m, s]
