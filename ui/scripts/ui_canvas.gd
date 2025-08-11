extends Control

@export var ui_element: Control
@export var button: Button

func _ready():
	if button:
		button.pressed.connect(_on_button_pressed)
	if ui_element:
		ui_element.visible = false

func _on_button_pressed():
	if ui_element:
		ui_element.visible = !ui_element.visible
	

	
	
