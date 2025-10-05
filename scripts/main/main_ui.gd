extends CanvasLayer

# This script connects the main UI buttons to the rocket script functions.

func _ready():
	# Get references to the main nodes
	var rocket = get_node("../Rocket")
	var rocket_ui_container = find_child("RocketUI")
	var edit_button = find_child("EditButton", true, false)

	if not rocket or not rocket_ui_container:
		print("UI Error: Could not find Rocket node or RocketUI container.")
		return

	# --- Connect Buttons to Rocket Functions ---
	var add_button = rocket_ui_container.find_child("AddButton")
	if add_button: add_button.pressed.connect(rocket.add_module)

	var remove_button = rocket_ui_container.find_child("RemoveButton")
	if remove_button: remove_button.pressed.connect(rocket.remove_module)

	if edit_button:
		edit_button.pressed.connect(rocket.enter_edit_mode)
	else:
		# The original scene file has a weirdly placed edit button. Let's try to find it.
		var misplaced_edit_button = get_node_or_null("../CanvasLayer_Control_MenuBar#EditButton")
		if misplaced_edit_button:
			misplaced_edit_button.pressed.connect(rocket.enter_edit_mode)
			print("Connected misplaced edit button")
		else:
			print("UI Error: Edit button not found.")
	
	# --- Logic for Up/Down focus buttons ---
	var up_button = rocket_ui_container.find_child("UpButton")
	if up_button: up_button.pressed.connect(func(): change_focus(rocket, 1)) # Up is higher index

	var down_button = rocket_ui_container.find_child("DownButton")
	if down_button: down_button.pressed.connect(func(): change_focus(rocket, -1)) # Down is lower index

	# Initialize focus on the first module if it exists
	if rocket.get_module_count() > 0:
		rocket.focus_module(0)


func change_focus(rocket_node: Node3D, direction: int):
	if rocket_node.is_editing: return

	var current_focus = rocket_node.get_focused_module_index()
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