extends MarginContainer

enum states {MAIN, HOST, JOIN}
var state

onready var main = $Main
onready var join = $Join
onready var join_code_text = $Join/VBoxContainer/CenterContainer/PanelContainer/Input

signal host_pressed
signal connect_pressed(passcode)

func _ready() -> void:
	state = states.MAIN
	main.get_node("VBoxContainer/JoinButton").connect("pressed", self, "_join_pressed")
	main.get_node("VBoxContainer/HostButton").connect("pressed", self, "_host_pressed")
	join.get_node("VBoxContainer/ConnectButton").connect("pressed", self, "_connect_pressed")
	join.get_node("VBoxContainer/BackButton").connect("pressed", self, "_back_pressed")


func _host_pressed() -> void:
	state = states.HOST
	emit_signal("host_pressed")


func _join_pressed() -> void:
	state = states.JOIN
	join_code_text.grab_focus()

func _connect_pressed() -> void:
	emit_signal("connect_pressed", join_code_text.text.to_upper())
	
func _back_pressed() -> void:
	if state == states.JOIN:
		state = states.MAIN
	
func _process(_delta: float) -> void:
	if state == states.MAIN:
		join.hide()
		main.show()
	if state == states.JOIN:
		main.hide()
		join.show()
		
