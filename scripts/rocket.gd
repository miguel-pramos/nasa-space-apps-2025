extends Node3D

@export var camera: Camera3D

var module_scenes: Dictionary = {}

var base: Node3D
var pinnacle: Node3D
var modules: Array[Node3D] = []
var focused_module: Node3D

var module_height = 1.0

func _ready():
	module_scenes = {
		"module": load("res://scenes/rocket_modules/module.tscn")
	}
	print("module_scenes: ", module_scenes)

	base = find_child("Base")
	pinnacle = find_child("Pinnacle")
	var initial_module = find_child("Module1")
	if initial_module:
		modules.append(initial_module)

func add_module(module_type: String):
	if not module_scenes.has(module_type):
		print("Module type not found: ", module_type)
		return

	var module_scene = module_scenes[module_type]
	var new_module = module_scene.instantiate()

	# Pass the main camera to the module
	if new_module.has_method("set"): # Check if it's a valid node with properties
		new_module.set("main_camera", camera)

	var new_position = Vector3.ZERO
	if not modules.is_empty():
		var top_module = modules[-1]
		new_position = top_module.position + Vector3.UP * module_height
	else:
		new_position = base.position + Vector3.UP * module_height
	
	new_module.position = new_position
	modules.append(new_module)
	add_child(new_module)

	update_pinnacle_position()

func remove_module():
	if modules.size() < 2:
		return

	var top_module = modules.pop_back()
	top_module.queue_free()
	
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

func focus_module(index: int):
	if index < 0 or index >= modules.size():
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position:y", modules[-1].position.y + 3, 0.5).set_trans(Tween.TRANS_SINE)

	
	for i in range(modules.size()):
		if i == index:
			var focused_module = modules[i]

	
func activate_module():
	if focused_module.has_method("set"):
		focused_module.set("active", true)

func get_module_count() -> int:
	return modules.size()
