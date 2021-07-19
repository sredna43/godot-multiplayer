extends Node

var level1 = preload("res://scenes/levels/TestLevel_1.tscn")

func _ready():
	var level1_instance = level1.instance()
	add_child(level1_instance)
