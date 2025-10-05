extends Node3D

var camera_rotation:Vector3

var zoom:float = 30.0 # 30 = Standard zoom level, in meters

@onready var camera = $Camera

func _ready():
	
	camera_rotation = rotation_degrees # Initial rotation
	
	pass

func _process(delta):
	
	# Set position and rotation to targets
	
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	# Smoothly update zoom
	
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), delta * 8)
	
	handle_input(delta)

# Handle input

func handle_input(_delta):
	
	# Rotation
	
	# Zoom in/outdas
	
	if Input.is_action_just_released("zoom_in"):
		zoom = max(15, zoom - 5) # 15 = Minimum zoom level, in meters
		
	if Input.is_action_just_released("zoom_out"):
		zoom = min(80, zoom + 5) # 80 = Maximum zoom level, in meters
	
	# Back to center

func _input(event):
	
	# Rotate camera using mouse (hold 'middle' mouse button)
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			camera_rotation += Vector3(0, -event.relative.x / 10, 0)
