extends Button

@export var music_stream: AudioStream  # Assign in the editor

# Custom icon regions (assuming a TextureAtlas with regions for play/stop icons)
@export var play_icon_region: Rect2
@export var stop_icon_region: Rect2

var _is_playing := false

func _ready():
	pressed.connect(_on_button_pressed)
	_update_icon()

func _on_button_pressed():
	if _is_playing:
		# Stop music
		AudioManager.stop_music(1.0)  # Fade out over 2 sec
		_is_playing = false
	else:
		# Start music
		AudioManager.play_music(music_stream, true, 0.5)  # Fade in over 2 sec
		_is_playing = true
	_update_icon()

func _update_icon():
	var stylebox := get_theme_stylebox("normal")
	if stylebox is StyleBoxTexture:
		if _is_playing:
			stylebox.region_rect = stop_icon_region  # Use "stop" icon region
		else:
			stylebox.region_rect = play_icon_region  # Use "play" icon region
