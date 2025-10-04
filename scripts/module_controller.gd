extends Node3D

@export var active: bool = false:
    set(value):
        if active != value:
            active = value
            update_state()

var camera: Camera3D
var canvas_layer: CanvasLayer
var builder: Node3D

func _ready():
    camera = find_child("Camera")
    canvas_layer = find_child("CanvasLayer")
    builder = find_child("Builder")
    update_state()

func update_state():
    if camera:
        camera.current = active
    if canvas_layer:
        canvas_layer.visible = active
    if builder:
        builder.set_process(active)
        builder.set_physics_process(active)
        builder.set_process_input(active)
