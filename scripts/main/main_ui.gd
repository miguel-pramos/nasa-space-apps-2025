extends CanvasLayer

var rocket: Node3D

func _ready():
	# Assuming the rocket is at this path
	rocket = get_node("/root/Main/Rocket") 

	var addButton = find_child("AddButton")
	if addButton:
		addButton.pressed.connect(on_add_button_pressed)

	var removeButton = find_child("RemoveButton")
	if removeButton:
		removeButton.pressed.connect(on_remove_button_pressed)

func on_add_button_pressed():
	if rocket:
		rocket.add_module("module")

func on_remove_button_pressed():
	if rocket:
		rocket.remove_module()
