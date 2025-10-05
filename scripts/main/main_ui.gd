extends CanvasLayer

# This script connects the main UI buttons to the rocket script functions.

func _ready():
	# Get references to the main nodes
	var rocket = get_node("../Rocket")
	var rocket_ui_container = find_child("Control") # The MarginContainer for the rocket UI

	if not rocket or not rocket_ui_container:
		print("UI Error: Could not find Rocket node or UI container.")
		return

	# Give the rocket a reference to the UI so it can hide/show it
	rocket.rocket_ui = rocket_ui_container

	# --- Connect Buttons to Rocket Functions ---
	var addButton = find_child("AddButton")
	if addButton: addButton.pressed.connect(rocket.add_module)

	var removeButton = find_child("RemoveButton")
	if removeButton: removeButton.pressed.connect(rocket.remove_module)

	var editButton = find_child("EditButton")
	if editButton: editButton.pressed.connect(rocket.enter_edit_mode)
	
	# --- Logic for Up/Down focus buttons ---
	var upButton = find_child("UpButton")
	if upButton: upButton.pressed.connect(func(): change_focus(rocket, 1))

	var downButton = find_child("DownButton")
	if downButton: downButton.pressed.connect(func(): change_focus(rocket, -1))

	# Initialize focus on the first module if it exists
	rocket.focus_module(0)


func change_focus(rocket_node: Node3D, direction: int):
	var current_focus = rocket_node.get("focused_module_idx")
	var num_modules = rocket_node.get_module_count()
	
	if num_modules == 0:
		rocket_node.focus_module(-1)
		return

	var next_focus = current_focus + direction

	# Wrap around
	if next_focus >= num_modules:
		next_focus = 0
	elif next_focus < 0:
		next_focus = num_modules - 1
	
	rocket_node.focus_module(next_focus)
