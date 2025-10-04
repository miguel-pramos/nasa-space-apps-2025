extends CanvasLayer

var rocket: Node3D
var focused_module_index: int = 0

func _ready():
	# Assuming the rocket is at this path
	rocket = get_node("../Rocket") 

	var addButton = find_child("AddButton")
	if addButton:
		addButton.pressed.connect(on_add_button_pressed)
	
	var activateButton = find_child("ActivateButton")
	if activateButton:
		activateButton.pressed.connect(on_activate_button_pressed)
	
	var removeButton = find_child("RemoveButton")
	if removeButton:
		removeButton.pressed.connect(on_remove_button_pressed)

	var upButton = find_child("UpButton")
	if upButton:
		upButton.pressed.connect(on_up_button_pressed)

	var downButton = find_child("DownButton")
	if downButton:
		downButton.pressed.connect(on_down_button_pressed)

func on_add_button_pressed():
	if rocket:
		var module_count = rocket.get_module_count()
		var is_focused_on_top = (focused_module_index == module_count - 1)

		rocket.add_module("module")

		if is_focused_on_top:
			on_up_button_pressed()

func on_remove_button_pressed():
	if rocket:
		var module_count = rocket.get_module_count()
		var is_focused_on_top = (focused_module_index == module_count - 1)

		rocket.remove_module()

		if is_focused_on_top:
			on_down_button_pressed()

func on_up_button_pressed():
	print("Up button pressed")
	focused_module_index += 1
	if rocket:
		var module_count = rocket.get_module_count()
		print("Module count: ", module_count)
		if focused_module_index >= module_count:
			focused_module_index = 0
		print("Focused module index: ", focused_module_index)
		rocket.focus_module(focused_module_index)

func on_down_button_pressed():
	print("Down button pressed")
	focused_module_index -= 1
	if rocket:
		var module_count = rocket.get_module_count()
		print("Module count: ", module_count)
		if focused_module_index < 0:
			if module_count > 0:
				focused_module_index = module_count - 1
			else:
				focused_module_index = 0
		print("Focused module index: ", focused_module_index)
		rocket.focus_module(focused_module_index)
		
func on_activate_button_pressed():
	if rocket:
		rocket.activate_module()
