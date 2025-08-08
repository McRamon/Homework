extends Node
class_name RetreatState

func on_retreat():
	if current_target == null or myself == null:
		myself.current_state = MobDefines.State.IDLE
		return
		
	var dir_to_target = current_target.global_position.direction_to(myself.global_position)
	
	var found := false
	var tries := 0
	var navigator := myself.get_node("mob_navigator")
	var map_rid = navigator.get_navigation_map()
	
	while not found and tries < 10:
		var random_angle = randf_range(0.0, TAU)
		var escape_direction = Vector2.RIGHT.rotated(random_angle).normalized()
		var distance = randf_range(myself.chase_range, myself.chase_range + 200)
		var candidate_position = myself.global_position + escape_direction * distance
		
		var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
		
		if candidate_position.distance_to(closest_point) < 400:
			navigator.target_position = closest_point
			retreat_target_position = closest_point
			found = true
			print("MOB ", myself, " is escaping to: ", retreat_target_position)
		else:
			tries += 1
			
	if not found:
		print(" MOB ", myself, " tried to escape, but could not")
