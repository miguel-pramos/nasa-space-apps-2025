extends Node3D

@export var cost: int = 100

@export var active: bool = false:
	set(value):
		if active != value:
			active = value
			update_state()

@export var main_camera: Camera3D

var module_camera: Camera3D
var canvas_layer: CanvasLayer
var builder: Node3D

func _ready():
	module_camera = find_child("Camera")
	canvas_layer = find_child("CanvasLayer")
	builder = find_child("Builder")
	update_state()

func update_state():
	if module_camera:
		module_camera.current = active
	
	if main_camera:
		main_camera.current = not active

	if canvas_layer:
		canvas_layer.visible = active
		
	if builder:
		builder.set_process(active)
		builder.set_physics_process(active)
		builder.set_process_input(active)
