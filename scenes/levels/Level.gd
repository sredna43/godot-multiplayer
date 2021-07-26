extends Node2D

signal leave

onready var scene_handler = get_parent()
onready var hud = $HUD
onready var player: KinematicBody2D = $YSort/Player
var start_pos

func _ready() -> void:
	player.set_global_position(scene_handler.player_level_start)
	player.paused = true
	if false:
		emit_signal("leave")
	var _error = hud.connect("timer_complete", self, "_go")
	_error = hud.connect("leave_button_pressed", self, "_leave_game")

func start_race():
	hud.start_timer()

func _go():
	player.paused = false

func _leave_game():
	emit_signal("leave")

func display_win(text):
	hud.display_win(text)
