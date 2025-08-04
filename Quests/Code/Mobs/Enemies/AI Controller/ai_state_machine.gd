extends Node
class_name AIStateMachine

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK
}

@export var control_ai: ControlComponentAi
@export var patrol_points: Array[Vector2] = []
@export var chase_range: float = 200.0
@export var attack_range: float = 40.0
@export var player_path: NodePath

var current_state = State.IDLE
var patrol_index = 0
var player: Node2D

func _ready():
	player = get_node(player_path)
	_set_state(State.PATROL)

func _physics_process(delta):
	match current_state:
		State.IDLE:
			_idle_state()
		State.PATROL:
			_patrol_state()
		State.CHASE:
			_chase_state()
		State.ATTACK:
			_attack_state()

func _set_state(new_state):
	current_state = new_state

func _idle_state():
	# Wait or look around
	if player.global_position.distance_to(owner.global_position) < chase_range:
		_set_state(State.CHASE)

func _patrol_state():
	if patrol_points.is_empty():
		return
	if control_ai.navigator.is_navigation_finished():
		patrol_index = (patrol_index + 1) % patrol_points.size()
		control_ai.set_target(patrol_points[patrol_index])
	if player.global_position.distance_to(owner.global_position) < chase_range:
		_set_state(State.CHASE)

func _chase_state():
	control_ai.set_target(player.global_position)
	if owner.global_position.distance_to(player.global_position) <= attack_range:
		_set_state(State.ATTACK)
	elif owner.global_position.distance_to(player.global_position) > chase_range * 1.5:
		_set_state(State.PATROL)

func _attack_state():
	print("Enemy attacking player!")
	# TODO: Add attack logic here
	if owner.global_position.distance_to(player.global_position) > attack_range:
		_set_state(State.CHASE)
