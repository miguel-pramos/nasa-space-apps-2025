extends MarginContainer

var _is_animating: bool = false
var _on_screen_position: Vector2

func _ready() -> void:
	_on_screen_position = position

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interface"):
		toggle_animated()
		get_viewport().set_input_as_handled()

func toggle_animated() -> void:
	if _is_animating:
		return

	_is_animating = true
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	var off_screen = Vector2(get_viewport_rect().size.x, position.y)

	if visible:
		# Slide out to the right
		tween.tween_property(self, "position", off_screen, 0.4)
		tween.chain().tween_callback(hide)
	else:
		# Slide in from the left
		position = off_screen
		show()
		tween.tween_property(self, "position", _on_screen_position, 0.4)

	tween.chain().tween_callback(_on_animation_finished)

func _on_animation_finished() -> void:
	_is_animating = false
