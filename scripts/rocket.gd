extends Node3D

@export var camera: Camera3D
@export var module: Structure

var base: Node3D
var pinnacle: Node3D
var modules: Array[Node3D] = []
var focused_module_idx: int = -1
var original_material: Material
var original_materials: Dictionary = {}

var module_height = 1.0

func _ready():
	base = find_child("Base")
	pinnacle = find_child("Pinnacle")
	
func find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found = find_mesh_instance(child)
		if found:
			return found
	return null

func add_module():
	var new_module_model = module.model.instantiate()
	
	if not original_material:
		var mesh_instance = find_mesh_instance(new_module_model)
		if mesh_instance:
			original_material = mesh_instance.get_active_material(0)
	
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

	update_pinnacle_position()

func remove_module():
	if modules.size() < 1:
		return

	Global.resources.money += module.price
	
	var to_be_deleted_module = modules.pop_back()
	to_be_deleted_module.queue_free()
	
	update_pinnacle_position()

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

func focus_module(index: int):
	# Un-highlight the previously focused module
	if focused_module_idx != -1 and focused_module_idx < modules.size():
		set_highlight(modules[focused_module_idx], false)

	if index < 0 or index >= modules.size():
		focused_module_idx = -1
		return

	# Highlight the new module
	set_highlight(modules[index], true)

	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position:y", modules[index].position.y + 3, 0.5).set_trans(Tween.TRANS_SINE)

	focused_module_idx = index

	
func activate_module():
	if modules[focused_module_idx].has_method("set"):
		modules[focused_module_idx].set("active", true)

func get_module_count() -> int:
	return modules.size()
