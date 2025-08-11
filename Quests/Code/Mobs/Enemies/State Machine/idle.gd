extends Node
class_name IdleState

var timer_timing : bool = false
var is_idle:= false

func run(mob: CharacterBody2D, navigator: NavigationAgent2D):
	if mob == null:
		return
	if (!navigator.is_navigation_finished() or timer_timing) and is_idle:
		return
	is_idle = true
	var map_rid = navigator.get_navigation_map()
	var radius = 64.0
	
	var random_offset = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(10, radius)
	var candidate_position = mob.global_position + random_offset
	var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
	
	if candidate_position.distance_to(closest_point) < radius:
		navigator.target_position = closest_point
		timer_timing = true
		get_parent().start_timer(randf_range(5.0, 15.0), self, "_on_timer_timeout")
		print(mob, " selected a point to move to, it is ", mob.global_position.distance_to(closest_point), "pixels away")
	else:
		return

			
func _on_timer_timeout():
	timer_timing = false
