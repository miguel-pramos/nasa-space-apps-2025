extends Node

const CUSTOM_CURSOR = preload("res://sprites/cursors/cursor_none.svg")

func _ready() -> void:
	var hotspot = Vector2(16, 16)
	
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR, Input.CURSOR_ARROW, hotspot)
	
