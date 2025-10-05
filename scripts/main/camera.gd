extends Camera3D

signal focus_animation_finished

@export var rotation_speed: float = 0.1
var rotation_point: Vector3 = Vector3.ZERO
var rotation_direction: Vector3 = Vector3.UP

var is_transitioning = false

func _ready():
	focus_animation_finished.connect(on_focus_animation_finished)

func _process(delta):
	if is_transitioning: return # Pause orbiting during vertical movement

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
	
	await tween.finished
	emit_signal("focus_animation_finished")

func on_focus_animation_finished():
	GameEvents.emit_signal("intro_animation_finished")

func move_vertically_to(new_y_level: float):
	if is_transitioning: return

	var y_delta = new_y_level - rotation_point.y
	if abs(y_delta) < 0.01: return # Already there, no need to move

	is_transitioning = true

	var tween = get_tree().create_tween()
	tween.set_parallel()

	var new_cam_pos = transform.origin + Vector3(0, y_delta, 0)
	var new_rot_point = rotation_point + Vector3(0, y_delta, 0)

	tween.tween_property(self, "transform:origin", new_cam_pos, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_point", new_rot_point, 0.5).set_trans(Tween.TRANS_SINE)

	await tween.finished
	is_transitioning = false
