extends Node2D

onready var passcode_label = $HUD/Labels/CenterContainer/VBoxContainer/PasscodeLabel
onready var players_label = $HUD/Labels/CenterContainer/VBoxContainer/PlayersLabel
onready var host_controls = $HUD/HostControls
onready var normal_controls = $HUD/BasicControls
onready var scene_handler = get_parent()
onready var player = $YSort/Player
var rng = RandomNumberGenerator.new()

signal leave
signal start_game

func _ready() -> void:
	rng.randomize()
	player.position = Vector2(rng.randf_range(9, 67) * 10, 180)
	passcode_label.text = "Lobby code: " + scene_handler.passcode.to_upper()
	if scene_handler.is_host:
		host_controls.show()
		normal_controls.hide()
	else:
		host_controls.hide()
		normal_controls.show()

func _process(_delta: float) -> void:
	players_label.text = "Players connected: " + str(scene_handler.players_connected) + "/10"


func _on_StartButton_pressed() -> void:
	emit_signal("start_game")


func _on_LeaveButton_pressed() -> void:
	emit_signal("leave")
