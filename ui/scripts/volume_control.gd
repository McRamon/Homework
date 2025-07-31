extends HBoxContainer

@export var bus_name: String = "Master"  # Assign "Music", "SFX", etc. in editor
@export var step: float = 0.05           # Volume change per click (5%)
@export var bar_max_width: float = 76   # Max width for full volume bar

@onready var button_decrease := $music_decrease
@onready var button_increase := $music_increase
@onready var volume_bar := $VolumeBar

func _ready():
	button_decrease.pressed.connect(_on_decrease_pressed)
	button_increase.pressed.connect(_on_increase_pressed)
	_update_volume_bar()

func _on_decrease_pressed():
	_adjust_volume(-step)

func _on_increase_pressed():
	_adjust_volume(step)

func _adjust_volume(delta: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(bus_idx)
	var current_linear = db2linear(current_db)
	var new_linear = clamp(current_linear + delta, 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus_idx, linear2db(new_linear))
	_update_volume_bar()

func _update_volume_bar():
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(bus_idx)
	var current_linear = db2linear(current_db)
	volume_bar.size.x = current_linear * bar_max_width

# Helpers
func linear2db(volume: float) -> float:
	if volume <= 0:
		return -80  # Silence
	return 20 * log(volume) / log(10)

func db2linear(db: float) -> float:
	return pow(10, db / 20.0)
