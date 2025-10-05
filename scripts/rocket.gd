extends Node3D

@export var camera: Camera3D
@export var module: Structure

# The scene to instantiate for each module
const SCENARIO_SCENE = preload("res://scenes/scenarios/scenario_1.tscn")

var base: Node3D
var pinnacle: Node3D

var modules: Array[Node3D] = []
var scenario_instances: Array[Node3D] = []

var focused_module_idx: int = -1
var original_materials: Dictionary = {}
var module_height = 1.0

# A reference to the main UI so we can hide/show it
var rocket_ui: Control

func _ready():
	base = find_child("Base")
	pinnacle = find_child("Pinnacle")

func add_module():
	# --- Instantiate Module --- 
	var new_module_model = module.model.instantiate()
	if Global.resources.money < module.price:
		print("Not enough materials to build module")
		new_module_model.queue_free()
		return
	Global.resources.money -= module.price

	var new_position = Vector3.ZERO
	if not modules.is_empty():
		var top_module = modules[-1]
		new_position = top_module.position + Vector3.UP * module_height
	else:
		new_position = base.position + Vector3.UP * module_height
	
	new_module_model.position = new_position
	modules.append(new_module_model)
	add_child(new_module_model)

	# --- Instantiate Associated Scenario --- 
	var new_scenario = SCENARIO_SCENE.instantiate()
	var new_module_index = modules.size() - 1
	new_scenario.init(new_module_index) # Pass the index to the new instance
	new_scenario.back_to_assembly_requested.connect(exit_edit_mode)
	new_scenario.visible = false # Keep it hidden
	scenario_instances.append(new_scenario)
	get_tree().get_root().add_child(new_scenario) # Add to the main scene tree

	update_pinnacle_position()

func remove_module():
	if modules.size() < 1:
		return

	Global.resources.money += module.price
	
	# Remove module and its associated scenario instance
	var to_be_deleted_module = modules.pop_back()
	to_be_deleted_module.queue_free()
	var to_be_deleted_scenario = scenario_instances.pop_back()
	to_be_deleted_scenario.queue_free()
	
	update_pinnacle_position()


func enter_edit_mode():
	if focused_module_idx < 0 or focused_module_idx >= scenario_instances.size():
		return
	
	print("Entering edit mode for module: ", focused_module_idx)
	# Hide rocket and its UI
	if rocket_ui: rocket_ui.visible = false
	self.visible = false
	
	# Show the specific scenario instance
	var scenario = scenario_instances[focused_module_idx]
	scenario.visible = true

func exit_edit_mode():
	print("Exiting edit mode")
	# Hide all scenario instances
	for scenario in scenario_instances:
		scenario.visible = false
	
	# Show rocket and its UI
	if rocket_ui: rocket_ui.visible = true
	self.visible = true


# --- Helper and existing functions below ---

func update_pinnacle_position():
	if pinnacle:
		var pinnacle_position = Vector3.ZERO
		if not modules.is_empty():
			var top_module = modules[-1]
			pinnacle_position = top_module.position + Vector3.UP * module_height
			focus_module(-1)
		else:
			pinnacle_position = base.position + Vector3.UP * module_height
		pinnacle.position = pinnacle_position

func focus_module(index: int):
	if focused_module_idx != -1 and focused_module_idx < modules.size():
		set_highlight(modules[focused_module_idx], false)

	if index < 0 or index >= modules.size():
		focused_module_idx = -1
		return

	set_highlight(modules[index], true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position:y", modules[index].position.y + 3, 0.5).set_trans(Tween.TRANS_SINE)
	focused_module_idx = index

func set_highlight(node, highlight):
	if node is MeshInstance3D:
		var material = node.get_active_material(0)
		if material:
			if highlight:
				original_materials[node] = material
				var new_material = material.duplicate()
				new_material.albedo_color = Color.YELLOW
				node.set_surface_override_material(0, new_material)
			elif original_materials.has(node):
				node.set_surface_override_material(0, original_materials.get(node))
				original_materials.erase(node)

	for child in node.get_children():
		set_highlight(child, highlight)

func get_module_count() -> int:
	return modules.size()
