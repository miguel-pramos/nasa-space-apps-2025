extends Node3D

signal back_to_assembly_requested

var module_index: int = -1

func _ready():
	var back_button = get_node("CanvasLayer/BackButton")
	if back_button:
		back_button.pressed.connect(on_back_button_pressed)
	else:
		print("Error: BackButton not found in scenario scene.")

# This function will be called by the rocket script after instantiation
func init(p_module_index: int):
	module_index = p_module_index
	print("This scenario instance is now configured for module: ", module_index)
	# You can now use this index to load specific data for this module

func on_back_button_pressed():
	emit_signal("back_to_assembly_requested")
