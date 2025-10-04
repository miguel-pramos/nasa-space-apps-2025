extends Camera3D

@export var rotation_speed: float = 0.1

func _process(delta):
	# Create a rotation transform around the Y axis
	var rotation = Transform3D.IDENTITY.rotated(Vector3.UP, rotation_speed * delta)
	# Apply this rotation to the camera's current transform
	transform = rotation * transform
