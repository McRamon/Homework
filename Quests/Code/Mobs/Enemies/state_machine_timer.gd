extends Timer
var number : int = 0

func _ready():
	number = randf_range(0, 10000000)
