extends Node2D
class_name Spawner

@export var spawn_list: Array[PackedScene] = []
@export var spawn_once: bool = true
@export var random_rotation: bool = false
@export var patrol_points_for_mob : Array[Node2D]

signal spawner_finished(spawned_entities: Array)

func _ready():
	await get_tree().process_frame
	print("Spawner ", self, " is ready.")
	if spawn_once:
		spawn_random()
	$spawner_sprite.visible = false
		
func spawn_random() -> Node2D:
	if spawn_list.is_empty():
		push_warning("Spawner ", self, " has no entities to spawn!")
		return null
		
	var random_index = randi() % spawn_list.size()
	var scene_to_spawn = spawn_list[random_index]
	var instance = scene_to_spawn.instantiate() as Node2D
	print(self, " selected a mob to spawn: ", instance)
	
	instance.global_position = global_position
	if random_rotation:
		instance.rotation = randf_range(0, TAU)
	for toilet in patrol_points_for_mob:
		var toilet_hole = toilet.global_position
		instance.patrol_points.append(toilet_hole)
		
	get_parent().add_child(instance)
	print("SPAWNED: ", instance.is_inside_tree())
	emit_signal("spawner_finished", instance)
	get_parent().alive_enemies.append(instance)
	return instance
