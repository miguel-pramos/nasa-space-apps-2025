extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scena_intro.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/setings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
