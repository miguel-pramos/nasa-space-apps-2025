extends Node3D

@export var camera: Camera3D
@export var module: Structure

var base: Node3D
var pinnacle: Node3D
var modules: Array[Node3D] = []
var focused_module_idx: int

var module_height = 1.0

func _ready():
	base = find_child("Base")
	pinnacle = find_child("Pinnacle")
	var initial_module = find_child("Module")
	if initial_module:
		modules.append(initial_module)

func add_module():
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

	update_pinnacle_position()

func remove_module():
	if modules.size() < 2:
		return
	
	if Global.resources.max_money >= Global.resources.money + module.price:
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

func focus_module(index: int):
	if index < 0 or index >= modules.size():
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position:y", modules[index].position.y + 3, 0.5).set_trans(Tween.TRANS_SINE)

	
	for i in range(modules.size()):
		if i == index:
			focused_module_idx = i

	
func activate_module():
	if modules[focused_module_idx].has_method("set"):
		modules[focused_module_idx].set("active", true)

func get_module_count() -> int:
	return modules.size()
