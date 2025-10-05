extends Camera3D

@export var rotation_speed: float = 0.1
var rotation_point: Vector3 = Vector3.ZERO
var rotation_direction: Vector3 = Vector3.UP

func _process(delta):
	# Vector from rotation point to camera
	var vector_to_camera = transform.origin - rotation_point

	# Rotate the vector around the rotation direction
	vector_to_camera = vector_to_camera.rotated(rotation_direction, rotation_speed * delta)

	# New camera position
	transform.origin = rotation_point + vector_to_camera

	# Rotate the camera's orientation
	transform.basis = transform.basis.rotated(rotation_direction, rotation_speed * delta)

func change_rotation_axis(new_point: Vector3, new_direction: Vector3 = Vector3.UP):
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Smoothly change the rotation axis and point
	tween.tween_property(self, "rotation_point", new_point, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_direction", new_direction.normalized(), 1.0).set_trans(Tween.TRANS_SINE)

	# Animate the camera to look at the new point
	var target_transform = transform.looking_at(new_point)
	tween.tween_property(self, "transform", target_transform, 1.0).set_trans(Tween.TRANS_SINE)
