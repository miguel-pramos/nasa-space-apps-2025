extends Node

const SCENARIO_1 = preload("res://scenes/scenarios/scenario_1.tscn")
# Add other scenarios here, e.g.:
# const SCENARIO_2 = preload("res://scenes/scenarios/scenario_2.tscn")

var instantiation_marker: Marker3D

func _ready():
	GameEvents.intro_animation_finished.connect(_on_intro_animation_finished)
	GameEvents.module_activated.connect(_on_module_activated)
	
	# Find the marker in the scene tree
	instantiation_marker = get_tree().get_root().find_child("InstantiationMarker", true, false)
	if not instantiation_marker:
		print("LevelManager Error: InstantiationMarker not found in the scene!")

func _on_intro_animation_finished():
	print("Intro animation finished. Ready to instantiate scenarios.")
	# This is a good place to instantiate a default or first scenario.
	# For example, we could start with scenario 1:
	instantiate_scenario(SCENARIO_1)

func _on_module_activated(module_index: int):
	print("Module %d activated." % module_index)
	
	# Example logic: instantiate a different scenario based on the module index
	match module_index:
		0:
			instantiate_scenario(SCENARIO_1)
		1:
			# instantiate_scenario(SCENARIO_2)
			print("Scenario for module 1 not defined yet.")
		_:
			print("No scenario defined for module index %d" % module_index)

func instantiate_scenario(scenario_scene: PackedScene):
	if not instantiation_marker:
		print("LevelManager Error: Cannot instantiate scenario, InstantiationMarker not found.")
		return

	# Optional: You might want to clear previous scenarios before adding a new one.

	var scenario_instance = scenario_scene.instantiate()
	# Set position using the global transform of the marker
	scenario_instance.global_position = instantiation_marker.global_position
	get_tree().get_root().add_child(scenario_instance)
	print("Instantiated scenario at marker's position.")
