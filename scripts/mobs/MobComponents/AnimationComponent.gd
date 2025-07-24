extends Node
class_name AnimationComponent


@export var mob: Node2D
var tween: Tween

func _ready():
	if !mob:
		push_error("mob sprite not detected")
		
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	
func animation_move():
	pass
	
func play_animation_idle():
	print(get_parent().name, " is idle")
	if !mob : return
	tween.kill()
	
	var original_position = mob.position
	
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	
	tween.tween_property(mob, "rotation_degrees", 2, 1)
	tween.parallel().tween_property(mob, "position:y", original_position.y - 1, 1)

	tween.tween_property(mob, "rotation_degrees", 0, 1)
	tween.parallel().tween_property(mob, "position:y", original_position.y, 1)
	
	tween.tween_property(mob, "rotation_degrees", -2, 1)
	tween.parallel().tween_property(mob, "position:y", original_position.y - 1, 1)

	tween.tween_property(mob, "rotation_degrees", 0, 1)
	tween.parallel().tween_property(mob, "position:y", original_position.y, 1)
