extends Node

var network = NetworkedMultiplayerENet.new()
var ip = Constants.ip
var port
var connected = false
var latency = 0.0
var client_clock = 0
var latency_array = []
var delta_latency = 0
var decimal_collector: float = 0

signal connected_to_server

func _ready() -> void:
	var _error = network.connect("connection_succeeded", self, "_on_connection_succeeded")
	_error = network.connect("connection_failed", self, "_on_connection_failed")
	
func _physics_process(delta):
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func connect_to_server(server_port = 0):
	port = server_port
	var _create_client_error = network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
func _on_connection_succeeded():
	print("Connected to server " + str(ip) + ":" + str(port))
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	connected = true
	emit_signal("connected_to_server")
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)
	
func _on_connection_failed():
	print("Failed to connect to server " + str(ip) + ":" + str(port))
	network.close_connection(10)
	
func disconnect_from_server():
	print("disconnecting from server")
	network.close_connection(10)
	connected = false
	get_tree().set_network_peer(null)
	
func send_start_game():
	print("sending start game")
	rpc_id(1, "start_game")
	
remote func ready_up():
	print("told to ready up")
	get_node("../SceneHandler").ready_up()
	rpc_id(1, "ready_to_race")
	
remote func start_race():
	print("Go!")
	get_node("../SceneHandler").start_race()

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

remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	
func determine_latency():
	if connected:
		rpc_id(1, "determine_latency", OS.get_system_time_msecs())
	
remote func winner(pid):
	if get_tree().get_network_unique_id() == pid:
		get_node("../SceneHandler").display_win("You won!!")
	else:
		get_node("../SceneHandler").display_win("player " + str(pid) + " won!")

remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() - 1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()
