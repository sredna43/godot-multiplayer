extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1998

func connect_to_server() -> void:
	var _create_client_state = network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	var _connection_succes_signal_status = network.connect("connection_succeeded", self, "_on_connection_succeeded")
	var _connection_fail_signal_status = network.connect("connection_failed", self, "_on_connection_failed")
	
func _on_connection_succeeded() -> void:
	print("Connected to server " + str(ip) + ":" + str(port))
	
func _on_connection_failed() -> void:
	print("Failed to connect to server " + str(ip) + ":" + str(port))

func _ready():
	connect_to_server()
