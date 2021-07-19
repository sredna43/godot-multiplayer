extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1998
var connected = false

func connect_to_server():
	var _create_client_error = network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	var _connection_succes_signal_status = network.connect("connection_succeeded", self, "_on_connection_succeeded")
	var _connection_fail_signal_status = network.connect("connection_failed", self, "_on_connection_failed")
	
func _on_connection_succeeded():
	print("Connected to server " + str(ip) + ":" + str(port))
	connected = true
	
func _on_connection_failed():
	print("Failed to connect to server " + str(ip) + ":" + str(port))

func _ready():
	connect_to_server()

func send_player_state(player_state):
	if connected:
		rpc_unreliable_id(1, "receive_player_state", player_state)

remote func spawn_player(pid, spawn_position):
	get_node("../SceneHandler").spawn_player(pid, spawn_position)

remote func despawn_player(pid):
	print("despawn " + str(pid))
	get_node("../SceneHandler").despawn_player(pid)

remote func receive_world_state(world_state):
	get_node("../SceneHandler").update_world_state(world_state)
