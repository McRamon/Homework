extends Resource
class_name StatusEffect

@export var name: String = "Unnamed Effect"
@export var description: String = "This should not appear, fix the bug"
@export var duration: float = 1.0  # in seconds
@export var icon: Texture2D
@export var visual_effect_scene: PackedScene


var elapsed_time: float = 0.0
var _visual_instance: Node2D

func on_apply(target: HealthComponent):
	if visual_effect_scene and target is HealthComponent:
		_visual_instance = visual_effect_scene.instantiate()
		target.get_parent().add_child(_visual_instance)
		if _visual_instance is Node2D:
			_visual_instance.position = Vector2.ZERO
		

func on_update(target: HealthComponent, delta: float) -> bool:
	if duration == 0:
		return false
	elapsed_time += delta
	return elapsed_time >= duration 

func on_expire(target: HealthComponent):
	if is_instance_valid(_visual_instance):
		_visual_instance.queue_free()
		_visual_instance = null
	
	if target.has_method("remove_status_effect"):
		target.remove_status_effect(self)
	on_removal(target)		
	
func on_removal(target: HealthComponent):
	pass
