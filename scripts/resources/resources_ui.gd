extends Node

var power_progress: TextureProgressBar
var fuel_progress: TextureProgressBar
var money_progress: TextureProgressBar

func _ready() -> void:
	power_progress = find_child("Power").find_child("Progress")
	fuel_progress = find_child("Fuel").find_child("Progress")
	money_progress = find_child("Money").find_child("Progress")


func _process(delta: float) -> void:
	money_progress.value = Global.resources.money / Global.resources.max_money * 100
