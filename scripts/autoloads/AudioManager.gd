extends Node

# Volume levels (0.0 - 1.0)
var master_volume := 1.0
var music_volume := 1.0
var ambience_volume := 1.0
var sfx_volume := 1.0

# Bus names (match Audio Bus Layout)
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_AMBIENCE := "Ambience"
const BUS_SFX := "SFX"

# Keep track of current music and ambience players
var current_music: AudioStreamPlayer = null
var current_ambience: AudioStreamPlayer = null

func _ready():
	# Apply initial volumes
	_update_bus_volumes()

# --- MUSIC ---
func play_music(stream: AudioStream, loop: bool = true, fade_time := 1.0):
	if current_music:
		_fade_out_player(current_music, fade_time)
	current_music = _create_stream_player(BUS_MUSIC, stream, loop)
	add_child(current_music)
	current_music.play()
	if fade_time > 0:
		_fade_in_player(current_music, fade_time)

func stop_music(fade_time := 1.0):
	if current_music:
		_fade_out_player(current_music, fade_time)

# --- AMBIENCE ---
func play_ambience(stream: AudioStream, loop: bool = true, fade_time := 1.0):
	if current_ambience:
		_fade_out_player(current_ambience, fade_time)
	current_ambience = _create_stream_player(BUS_AMBIENCE, stream, loop)
	add_child(current_ambience)
	current_ambience.play()
	if fade_time > 0:
		_fade_in_player(current_ambience, fade_time)

func stop_ambience(fade_time := 1.0):
	if current_ambience:
		_fade_out_player(current_ambience, fade_time)

# --- SFX ---
func play_sfx(stream: AudioStream, volume: float = 1.0):
	var sfx_player = _create_stream_player(BUS_SFX, stream)
	sfx_player.volume_db = linear2db(volume * sfx_volume * master_volume)
	sfx_player.connect("finished", Callable(sfx_player, "queue_free"))
	add_child(sfx_player)
	sfx_player.play()

# --- VOLUME CONTROL ---
func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	_update_bus_volumes()

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	_update_bus_volumes()

func set_ambience_volume(value: float):
	ambience_volume = clamp(value, 0.0, 1.0)
	_update_bus_volumes()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	_update_bus_volumes()

func _update_bus_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MASTER), linear2db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), linear2db(music_volume * master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_AMBIENCE), linear2db(ambience_volume * master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), linear2db(sfx_volume * master_volume))

# --- HELPERS ---
func _create_stream_player(bus_name: String, stream: AudioStream, loop: bool = true) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.bus = bus_name
	player.stream = stream
	player.autoplay = false
	if stream is AudioStreamWAV or stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = loop
	return player

func _fade_in_player(player: AudioStreamPlayer, duration: float):
	if player:
		player.volume_db = -80  # Start muted
		var tween = create_tween()
		tween.tween_property(player, "volume_db", 0, duration)

func _fade_out_player(player: AudioStreamPlayer, duration: float):
	if player:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", -80, duration).finished.connect(
			func (): _on_fade_out_complete(player)
		)

func _on_fade_out_complete(player: AudioStreamPlayer):
	player.stop()
	player.queue_free()
	if player == current_music:
		current_music = null
	elif player == current_ambience:
		current_ambience = null

func linear2db(volume: float) -> float:
	if volume <= 0:
		return -80  # Silence
	return 20 * (log(volume) / log(10))
