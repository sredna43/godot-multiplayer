extends Node

var main_menu = preload("res://scenes/guis/MainMenu.tscn")
var lobby = preload("res://scenes/levels/Lobby.tscn")
var level1 = preload("res://scenes/levels/TestLevel_1.tscn")
var player_spawn = preload("res://scenes/entities/player/PlayerTemplate.tscn")
var main_menu_instance
var level_instance: Node2D
var last_world_state = 0
var world_state_buffer: Array = []
var interpolation_offset = 100
var is_host: bool = false
var passcode = "123456"
var players_connected = 1
onready var http_request = HTTPRequest.new()
onready var lobby_server = Constants.lobby_server

func _ready():
	var _connect_error = DedicatedServer.connect("connected_to_server", self, "start")
	main_menu_instance = main_menu.instance()
	level_instance = lobby.instance()
	add_child(main_menu_instance)
	_connect_error = main_menu_instance.connect("host_pressed", self, "_host_game")
	_connect_error = main_menu_instance.connect("connect_pressed", self, "_connect_to_game")
	http_request.connect("request_completed", self, "_handle_lobby_return")
	add_child(http_request)
	
func start():
	remove_child(main_menu_instance)
	add_child(level_instance)
	
func _host_game():
	var _http_error = http_request.request(lobby_server + "/host")
	is_host = true
	
func _connect_to_game(code):
	var _http_error = http_request.request(lobby_server + "/join/" + code)
	is_host = false
	passcode = code
	
func _handle_lobby_return(_result, response_code, _headers, body):
	if OS.is_debug_build():
		print("body: " + str(JSON.parse(body.get_string_from_utf8()).result))
	if !body or response_code != 200:
		push_error("Could not reach lobby server")
		return
	var json = JSON.parse(body.get_string_from_utf8()).result
	if json.has("error"):
		print(json.error)
		return
	if is_host:
		DedicatedServer.connect_to_server(int(json.port))
		print("Passcode is " + json.passcode)
		passcode = json.passcode
	else:
		DedicatedServer.connect_to_server(int(json.port))

func spawn_player(pid: int, spawn_position: Vector2) -> void:
	if get_tree().get_network_unique_id() == pid:
		pass
	else:
		var new_player = player_spawn.instance()
		new_player.position = spawn_position
		new_player.name = str(pid)
		level_instance.get_node("YSort/OtherPlayers").add_child(new_player)

func despawn_player(pid):
	yield(get_tree().create_timer(0.2), "timeout")
	level_instance.get_node("YSort/OtherPlayers/" + str(pid)).queue_free()
	
func update_world_state(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta):
	if DedicatedServer.connected:
		players_connected = level_instance.get_node("YSort/OtherPlayers").get_child_count() + 1
		var render_time = DedicatedServer.client_clock - interpolation_offset
		if world_state_buffer.size() > 1:
			while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
				world_state_buffer.remove(0)
			if world_state_buffer.size() > 2:
				var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
				for player in world_state_buffer[2].keys():
					if str(player) == "T":
						continue
					if player == get_tree().get_network_unique_id():
						continue
					if not world_state_buffer[1].has(player):
						continue
					if level_instance.get_node("YSort/OtherPlayers").has_node(str(player)):
						var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
						level_instance.get_node("YSort/OtherPlayers/" + str(player)).move_player(new_position)
					else:
						print("Spawning player " + str(player))
						spawn_player(player, world_state_buffer[2][player]["P"])
			elif render_time > world_state_buffer[1].T:
				var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
				for player in world_state_buffer[1].keys():
					if str(player) == "T":
						continue
					if player == get_tree().get_network_unique_id():
						continue
					if not world_state_buffer[0].has(player):
						continue
					if level_instance.get_node("YSort/OtherPlayers").has_node(str(player)):
						var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
						var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
						level_instance.get_node("YSort/OtherPlayers/" + str(player)).move_player(new_position)
