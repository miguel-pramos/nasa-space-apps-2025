extends Node3D


func _on_finalizar_pressed() -> void:
	
	if $CanvasLayer/Control/Resources/Hygiene/Progress.value < Global.resources.max_hygine:
		get_tree().change_scene_to_file("res://scenes/NotHygie.tscn")
		
	#elif $CanvasLayer/Control/Resources/Food/Progress.value < Global.resources.max_food:
		#print("food")
		#print($CanvasLayer/Control/Resources/Food/Progress.value)
		#get_tree().change_scene_to_file("res://scenes/bad_food.tscn")
		
	elif $CanvasLayer/Control/Resources/Bathroom/Progress.value < Global.resources.max_bathrom:
		print("no bathroom")
		print($CanvasLayer/Control/Resources/Bathroom/Progress.value)
		get_tree().change_scene_to_file("res://scenes/no_bathroom.tscn")
		
	elif $CanvasLayer/Control/Resources/Bedroom/Progress.value < Global.resources.max_beddrom:
		get_tree().change_scene_to_file("res://scenes/volume_bedroom_bad.tscn")
		
	else:
		get_tree().change_scene_to_file("res://good_final.tscn")
		
