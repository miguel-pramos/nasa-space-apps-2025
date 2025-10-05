extends MarginContainer

@export 
var Module: Node3D

func _ready():
	
	var backButton = find_child("BackButton")
	if backButton:
		backButton.pressed.connect(on_back_button_pressed)


func on_back_button_pressed():
	if Module.has_method("set"):
		Module.set("active", false)
