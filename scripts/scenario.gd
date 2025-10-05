extends Node3D

@export var id: int
var global_camera: Camera3D
var camera: Camera3D

func _ready() -> void:
	camera = find_child("Camera")
	camera.current = true
