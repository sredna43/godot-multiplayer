extends Node2D

onready var passcode_label = $HUD/Labels/CenterContainer/VBoxContainer/PasscodeLabel
onready var players_label = $HUD/Labels/CenterContainer/VBoxContainer/PlayersLabel
onready var host_controls = $HUD/HostControls
onready var scene_handler = get_parent()

func _ready() -> void:
	passcode_label.text = "Lobby code: " + scene_handler.passcode.to_upper()
	if scene_handler.is_host:
		host_controls.show()
	else:
		host_controls.hide()

func _process(_delta: float) -> void:
	players_label.text = "Players connected: " + str(scene_handler.players_connected) + "/10"
