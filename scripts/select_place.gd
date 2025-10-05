extends Control


func _on_start_moon_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/moon_mission.tscn")


func _on_start_mart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mart_missions.tscn")

func _on_mart_button_mouse_entered():
	$AnimationPlayer.play("mars_hover")


func _on_mart_button_mouse_exited():
	$AnimationPlayer.play_backwards("mars_hover")
