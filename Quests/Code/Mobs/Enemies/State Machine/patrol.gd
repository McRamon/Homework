extends Node
class_name PatrolState

func on_patrol():
	if myself == null:
		return
	if myself.patrol_points.size() == 0 or myself.patrol_points.is_empty():
		print(" Mob ", myself, " has no patrol points, going IDLE")
		return
		
	var navigator = myself.get_node("mob_navigator")
	if not navigator.is_navigation_finished():
		return
		
	if not myself.has_meta("patrol_points"):
		myself.set_meta("patrol_index", 0)
	var patrol_index = myself.get_meta("patrol_index")
	
	# Clamp index to the valid range
	if patrol_index >= myself.patrol_points.size():
		patrol_index = 0
		
	var target_pos: Vector2 = myself.patrol_points[patrol_index]
	navigator.target_position = target_pos
	print(myself, " patrolling to ", target_pos)
	patrol_index = (patrol_index + 1) % myself.patrol_points.size()
	myself.set_meta("patrol_index", patrol_index)
