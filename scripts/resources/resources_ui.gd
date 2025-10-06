extends Node

const LERP_SPEED = 5.0

const COLOR_RED = Color("db4437")
const COLOR_YELLOW = Color("f4b400")
const COLOR_GREEN = Color("0f9d58")

var food_progress: TextureProgressBar
var bathroom_progress: TextureProgressBar
var money_progress: TextureProgressBar
var bedroom_progress: TextureProgressBar
var hygiene_progress: TextureProgressBar

var money_label: Label
var food_eval_label: Label
var bathroom_eval_label: Label
var bedroom_eval_label: Label
var hygiene_eval_label: Label

func _ready() -> void:
	var food_node = find_child("Food")
	food_progress = food_node.find_child("Progress")
	food_eval_label = food_node.find_child("EvaluationLabel")

	var bathroom_node = find_child("Bathroom")
	bathroom_progress = bathroom_node.find_child("Progress")
	bathroom_eval_label = bathroom_node.find_child("EvaluationLabel")

	var bedroom_node = find_child("Bedroom")
	bedroom_progress = bedroom_node.find_child("Progress")
	bedroom_eval_label = bedroom_node.find_child("EvaluationLabel")

	var hygiene_node = find_child("Hygiene")
	hygiene_progress = hygiene_node.find_child("Progress")
	hygiene_eval_label = hygiene_node.find_child("EvaluationLabel")
	
	var money_node = find_child("Money")
	money_progress = money_node.find_child("Progress")
	money_label = money_node.find_child("Label")

func get_evaluation_text(percentage: float, resource_name: String) -> String:
	if percentage == 0:
		return "No " + resource_name
	elif percentage < 34:
		return "Few " + resource_name + " units"
	elif percentage < 67:
		return "Adequate " + resource_name + " units"
	elif percentage < 100:
		return "Many " + resource_name + " units"
	else: # percentage == 100
		return "Maximum " + resource_name + " units"

func get_evaluation_color(percentage: float) -> Color:
	if percentage < 34:
		return COLOR_RED
	elif percentage < 67:
		return COLOR_YELLOW
	else:
		return COLOR_GREEN

func _process(delta: float) -> void:
	# Money
	var target_money_percent = 0.0
	if Global.resources.max_money > 0:
		target_money_percent = Global.resources.money / float(Global.resources.max_money) * 100
	money_progress.value = lerp(money_progress.value, target_money_percent, delta * LERP_SPEED)
	money_label.text = "Money: %d" % Global.resources.money

	# Food
	var target_food_percent = 0.0
	if Global.resources.max_food > 0:
		target_food_percent = Global.resources.food / float(Global.resources.max_food) * 100
	food_progress.value = lerp(food_progress.value, target_food_percent, delta * LERP_SPEED)
	food_eval_label.text = get_evaluation_text(target_food_percent, "Food")
	food_eval_label.self_modulate = get_evaluation_color(target_food_percent)

	# Bedroom
	var target_bedroom_percent = 0.0
	if Global.resources.max_beddrom > 0:
		target_bedroom_percent = Global.resources.beddrom / float(Global.resources.max_beddrom) * 100
	bedroom_progress.value = lerp(bedroom_progress.value, target_bedroom_percent, delta * LERP_SPEED)
	bedroom_eval_label.text = get_evaluation_text(target_bedroom_percent, "Bedroom")
	bedroom_eval_label.self_modulate = get_evaluation_color(target_bedroom_percent)

	# Bathroom
	var target_bathroom_percent = 0.0
	if Global.resources.max_bathrom > 0:
		target_bathroom_percent = Global.resources.bathdroom / float(Global.resources.max_bathrom) * 100
	bathroom_progress.value = lerp(bathroom_progress.value, target_bathroom_percent, delta * LERP_SPEED)
	bathroom_eval_label.text = get_evaluation_text(target_bathroom_percent, "Bathroom")
	bathroom_eval_label.self_modulate = get_evaluation_color(target_bathroom_percent)

	# Hygiene
	var target_hygiene_percent = 0.0
	if Global.resources.max_hygine > 0:
		target_hygiene_percent = Global.resources.hygine / float(Global.resources.max_hygine) * 100
	hygiene_progress.value = lerp(hygiene_progress.value, target_hygiene_percent, delta * LERP_SPEED)
	hygiene_eval_label.text = get_evaluation_text(target_hygiene_percent, "Hygiene")
	hygiene_eval_label.self_modulate = get_evaluation_color(target_hygiene_percent)
