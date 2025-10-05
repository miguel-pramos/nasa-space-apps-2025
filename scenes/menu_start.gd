extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scena_intro.tscn")


func _on_options_pressed() -> void:
	var scene = load("res://scenes/setings.tscn")
	var instance = scene.instantiate()
	add_child(instance)


func _on_exit_pressed() -> void:
	get_tree().quit()
