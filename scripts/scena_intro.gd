extends Control


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/select_place.tscn") # Replace with function body.


func _on_button_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_place.tscn") # Replace with function body.
