extends Button

@export var building_data: Resource
@onready var manager = $"../../../BuildingManager"

func _ready():
	text = building_data.name
	icon = building_data.icon_preview
	pressed.connect(func(): manager.request_build(building_data))
