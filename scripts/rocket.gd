extends Node3D

@export var base_scene: PackedScene
@export var pinnacle_scene: PackedScene

var module_scenes: Dictionary = {}

var base: Node3D
var pinnacle: Node3D
var modules: Array[Node3D] = []

var module_height = 1.0

func _ready():
	module_scenes = {
		"module": load("res://models/rocket_sides_a.tscn")
	}
	print("module_scenes: ", module_scenes)

	base = find_child("Base")
	pinnacle = find_child("Pinnacle")
	var initial_module = find_child("Module1")
	if initial_module:
		modules.append(initial_module)

func add_module(module_type: String):
	print("Adding module: ", module_type)
	print("Available modules: ", module_scenes.keys())
	if not module_scenes.has(module_type):
		print("Module type not found: ", module_type)
		return

	var module_scene = module_scenes[module_type]
	var new_module = module_scene.instantiate()

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
	if modules.is_empty():
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
		else:
			pinnacle_position = base.position + Vector3.UP * module_height
		
		pinnacle.position = pinnacle_position
