extends Button

@export var music_stream: AudioStream  # Assign in the editor

var _is_playing := false

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
		# Start music
		AudioManager.play_sfx(music_stream, 1)  # Fade in over 2 sec
