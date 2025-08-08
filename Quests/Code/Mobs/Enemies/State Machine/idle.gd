extends Node
class_name IdleState


func on_idle():
	if myself == null:
		return
	var navigator := myself.get_node("mob_navigator")
	if !navigator.is_navigation_finished() or timer_timing:
		return
	var map_rid = navigator.get_navigation_map()
	var radius = 50.0
	var found := false
	var tries = 0
	
	while not found and tries < 10:
		var random_offset = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(10, radius)
		var candidate_position = myself.global_position + random_offset
		var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
		
		if candidate_position.distance_to(closest_point) < 10.0:
			navigator.target_position = closest_point
			found = true
			timer_timing = true
			myself.get_tree().create_timer(randf_range(5.0, 15.0)).timeout.connect(func(): timer_timing = false)
			print(myself, " selected a point to move to, it is ", myself.global_position.distance_to(closest_point), "pixels away")
		else:
			tries += 1
