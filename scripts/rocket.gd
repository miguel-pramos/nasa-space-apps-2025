extends Node3D

@export var camera: Camera3D
# The scene for the module to be instanced
const MODULE_SCENE = preload("res://scenes/scenarios/scenario_1.tscn")

const MAX_MODULES = 4

@onready var modules: Array[Node3D] = []
@onready var focused_module_idx = -1

# UI references that will be set from main_ui.gd
var rocket_ui: Control
var module_ui: Control
var limit_popup: Control

var focus_selector: MeshInstance3D

var module_height = 4.0 # Assuming a fixed height for modules to stack them
var is_editing = false

@onready var ambient_node = get_node_or_null("../Ambient")

func _ready():
	# This is a bit of a hack because the UI is in a different branch.
	# A better way would be to use signals.
	# We wait for the parent to be ready and then get the UI nodes.
	await get_parent().ready
	var main_ui = get_node("/root/Main/CanvasLayer")
	if main_ui:
		rocket_ui = main_ui.find_child("RocketUI")
		module_ui = main_ui.find_child("ModuleUI")
		var back_button = module_ui.find_child("Back")
		if back_button:
			back_button.pressed.connect(exit_edit_mode)
		else:
			print("Rocket.gd: Back button not found in module_ui")
		
		limit_popup = main_ui.find_child("LimitPopup")
		if limit_popup:
			var close_button = limit_popup.find_child("CloseButton", true, false)
			if close_button:
				close_button.pressed.connect(func(): limit_popup.hide())
		else:
			print("Rocket.gd: LimitPopup not found.")
	else:
		print("Rocket.gd: Could not find CanvasLayer to get UI nodes.")

	# Create a selector mesh for visual feedback
	focus_selector = MeshInstance3D.new()
	var mesh = TorusMesh.new()
	mesh.inner_radius = 2.5
	mesh.outer_radius = 2.8
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.YELLOW
	mat.emission_enabled = true
	mat.emission = Color.YELLOW
	mat.emission_energy = 2.0
	focus_selector.mesh = mesh
	focus_selector.material_override = mat
	add_child(focus_selector)
	focus_selector.visible = false # Hide it initially
	update_ui_buttons_visibility()


func get_module_count() -> int:
	return modules.size()

func update_ui_buttons_visibility():
	if rocket_ui:
		var edit_button = rocket_ui.find_child("EditButton")
		if edit_button:
			edit_button.visible = (modules.size() > 0)
		
		var up_button = rocket_ui.find_child("UpButton")
		if up_button:
			up_button.visible = (modules.size() >= 2)

		var down_button = rocket_ui.find_child("DownButton")
		if down_button:
			down_button.visible = (modules.size() >= 2)

func add_module():
	if modules.size() >= MAX_MODULES:
		if limit_popup:
			limit_popup.show()
		print("Module limit reached!")
		return

	if is_editing: return

	var new_module_instance = MODULE_SCENE.instantiate()
	
	# Hide the UI of the new module
	var canvas_layer = new_module_instance.find_child("CanvasLayer")
	if canvas_layer:
		canvas_layer.visible = false
	
	modules.append(new_module_instance)
	add_child(new_module_instance)
	
	# Position the new module on top of the last one
	var module_y_pos = (modules.size() - 1) * module_height
	new_module_instance.position = Vector3(0, module_y_pos, 0)
	
	# Automatically focus the new module
	focus_module(modules.size() - 1)
	print("Added module. Total: ", get_module_count())
	update_ui_buttons_visibility()

func remove_module():
	if is_editing: return
	
	if focused_module_idx != -1 and modules.size() > 0:
		var module_to_remove = modules[focused_module_idx]
		modules.remove_at(focused_module_idx)
		module_to_remove.queue_free()
		
		print("Removed module. Total: ", get_module_count())

		# Re-focus
		if modules.size() > 0:
			var new_focus = min(focused_module_idx, modules.size() - 1)
			focus_module(new_focus)
		else:
			focused_module_idx = -1
			focus_module(-1) # Unfocus visual
			
	update_ui_buttons_visibility()
			
func enter_edit_mode():
	if focused_module_idx != -1 and not is_editing:
		is_editing = true
		
		var selected_module = modules[focused_module_idx]

		# Show the UI of the selected module
		var canvas_layer = selected_module.find_child("CanvasLayer")
		if canvas_layer:
			canvas_layer.visible = true

		var module_camera = selected_module.find_child("Camera", true, false)
		var builder = selected_module.get_node("View/Builder")
		if builder and builder.has_method("set_active"):
			builder.set_active(true)

		if not module_camera:
			print("Rocket.gd: No camera found in the module instance.")
			is_editing = false
			return

		# --- ISOLATION LOGIC ---
		# Hide other modules
		for module in modules:
			if module != selected_module:
				module.visible = false
		
		# Hide main scene elements
		if ambient_node:
			ambient_node.visible = false
		if focus_selector:
			focus_selector.visible = false
		# --- END ISOLATION LOGIC ---

		# Switch UI
		if rocket_ui: rocket_ui.hide()
		if module_ui: module_ui.show()
		
		# Switch Cameras
		camera.current = false
		module_camera.current = true
		
		print("Entering edit mode for module ", focused_module_idx)

func exit_edit_mode():
	if is_editing:
		is_editing = false
		
		if focused_module_idx != -1 and focused_module_idx < modules.size():
			var selected_module = modules[focused_module_idx]
			if selected_module:

				# Hide the UI of the selected module
				var canvas_layer = selected_module.find_child("CanvasLayer")
				if canvas_layer:
					canvas_layer.visible = false

				var module_camera = selected_module.find_child("Camera", true, false)
				if module_camera:
					module_camera.current = false
				var builder = selected_module.get_node("View/Builder")
				if builder and builder.has_method("set_active"):
					builder.set_active(false)

		# --- REVERT ISOLATION ---
		# Show all modules
		for module in modules:
			module.visible = true
			
		# Show main scene elements
		if ambient_node:
			ambient_node.visible = true
		# Make sure selector is visible and at the right place
		focus_module(focused_module_idx)
		# --- END REVERT ISOLATION ---

		# Switch UI
		if module_ui: module_ui.hide()
		if rocket_ui: rocket_ui.show()
		
		# Switch Cameras
		camera.current = true
		
		print("Exiting edit mode.")

func focus_module(idx: int):
	if is_editing: return
	if idx == focused_module_idx: return # No change

	var old_y_pos = 0.0
	if focused_module_idx != -1 and focused_module_idx < modules.size():
		old_y_pos = modules[focused_module_idx].global_position.y

	focused_module_idx = idx

	if focused_module_idx != -1 and focused_module_idx < modules.size():
		var new_focused_module = modules[focused_module_idx]
		var new_y_pos = new_focused_module.global_position.y
		
		# Move the selector
		focus_selector.global_position = new_focused_module.global_position
		focus_selector.visible = true
		
		# Move the camera vertically
		if camera and camera.has_method("move_vertically_to"):
			camera.move_vertically_to(new_y_pos)

		print("Focused module ", focused_module_idx)
	else:
		# Hide the selector
		focus_selector.visible = false
		print("Unfocused all modules.")

func get_focused_module_index() -> int:
	return focused_module_idx
