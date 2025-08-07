extends Node

enum State {
	IDLE,
	PATROL,
	RETREAT,
	ATTACK
}

enum MobType {
	PASSIVE,
	HOSTILE,
	AGRESSIVE
}

enum MobCombatState {
	ATTACKING,
	CHARGING,
	MOVING
}
