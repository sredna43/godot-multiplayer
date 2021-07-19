extends Node2D
class_name EntityState

export var tag: String = ""

func _ready() -> void:
	if tag:
		tag = tag.to_lower()
	else:
		tag = name.to_lower()
	
func enter(entity: KinematicBody2D) -> void:
	entity.animation_player.playback_speed = 1
	entity.animation_player.play(tag)
	
# Returns the next state to enter
func run(_entity: KinematicBody2D) -> String:
	return ""
	
func exit(_entity: KinematicBody2D) -> void:
	pass
