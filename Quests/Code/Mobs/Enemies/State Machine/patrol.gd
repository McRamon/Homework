extends Node
class_name PatrolState

var patrol_index := 0
var waiting := false
var wait_time := 5.0
var is_patroling:= false

func run(mob: CharacterBody2D, navigator: NavigationAgent2D):
	if mob == null or mob.patrol_points.is_empty():
		print(" Mob ", mob, " has no patrol points, going IDLE")
		return
	if waiting:
		return
	if not navigator.is_navigation_finished() and is_patroling:
		return
		
	if not mob.has_meta("patrol_index"):
		mob.set_meta("patrol_index", 0)
	var points_count := int(mob.patrol_points.size())
	patrol_index = clamp(int(mob.get_meta("patrol_index")), 0 , points_count - 1)
	
	var target_pos: Vector2 = mob.patrol_points[patrol_index]
	navigator.target_position = target_pos
	print(mob.mob_name, " patrolling to ", target_pos)
	patrol_index = (patrol_index + 1) % points_count
	mob.set_meta("patrol_index", patrol_index)
	waiting = true
	

	
func _on_wait_finished() -> void:
	waiting = false

func _on_mob_navigator_target_reached() -> void:
	waiting = true
	get_parent().timer.stop()
	get_parent().timer.wait_time = wait_time
	get_parent().timer.one_shot = true
	get_parent().timer.timeout.connect(_on_wait_finished, CONNECT_ONE_SHOT)
	get_parent().timer.start()
