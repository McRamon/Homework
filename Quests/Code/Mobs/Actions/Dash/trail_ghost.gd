extends Node2D

@export var lifetime := 0.25

var sprite: Sprite2D

func _ready():
	sprite = $ghost_sprite
	sprite.modulate = Color(1, 1, 1, 0.8)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "modulate", Color(0.5, 0, 0, 0.0), lifetime)
	tween.tween_property(sprite, "modulate:a", 0.0, lifetime)
	tween.finished.connect(queue_free)
