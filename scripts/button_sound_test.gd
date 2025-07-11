extends Button

# Preload your music file (adjust the path)
@export var music_stream: AudioStream  # (Optional: Assign in the editor)
# OR:
# const MY_MUSIC = preload("res://assets/music/background_music.ogg")

func _ready():
	# Connect button press to play music
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Play music (with fade-in and looping)
	AudioManager.play_music(music_stream, true, 2.0)  # Fade in over 2 sec
