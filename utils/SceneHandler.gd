extends Node

# Menus
var main_menu = preload("res://scenes/guis/MainMenu.tscn")
onready var main_menu_instance = main_menu.instance()

# Scenes to be instanced
var lobby = preload("res://scenes/levels/Lobby.tscn")
var level1 = preload("res://scenes/levels/TestLevel_1.tscn")

var levels = {"lobby": lobby, "level1": level1}
var current_level_instance

# Player template
var player_spawn = preload("res://scenes/entities/player/PlayerTemplate.tscn")

# World state variables sent by server
var last_world_state = 0
var world_state_buffer: Array = []
var interpolation_offset = 100

# Server connection variables + lobby stuff
var is_host: bool = false
var passcode = "123456"
var players_connected = 1
onready var http_request = HTTPRequest.new()
onready var lobby_server = Constants.lobby_server

# Random Number stuff
var rng = RandomNumberGenerator.new()
var player_level_start

func _ready():
	rng.randomize()
	var _connect_error = DedicatedServer.connect("connected_to_server", self, "start_lobby")
	http_request.connect("request_completed", self, "_handle_lobby_return")
	add_child(http_request)
	go_to_main_menu()
	
func start_lobby():
	change_level(levels.lobby)
	if is_host:
		current_level_instance.connect("start_game", self, "_start_game")
	
func go_to_main_menu():
	change_level(main_menu)
	var _connect_error = current_level_instance.connect("host_pressed", self, "_host_game")
	_connect_error = current_level_instance.connect("connect_pressed", self, "_connect_to_game")
	
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
		current_level_instance.get_node("YSort/OtherPlayers").add_child(new_player)

func despawn_player(pid):
	yield(get_tree().create_timer(0.2), "timeout")
	current_level_instance.get_node("YSort/OtherPlayers/" + str(pid)).queue_free()
	
func change_level(next_level):
	if current_level_instance:
		remove_child(current_level_instance)
		current_level_instance.queue_free()
	current_level_instance = next_level.instance()
	add_child(current_level_instance)
	if current_level_instance.get_class() == "Node2D":
		current_level_instance.connect("leave", self, "_leave_server")
		

func start_race():
	current_level_instance.start_race()

func _start_game():
	DedicatedServer.send_start_game()
	
func ready_up():
	player_level_start = Vector2(rng.randf_range(9, 67) * 10, 430)
	change_level(levels.level1)
	
func _leave_server():
	print("leaving server lobby")
	DedicatedServer.disconnect_from_server()
	go_to_main_menu()
	
func display_win(text):
	if current_level_instance.get_class() == "Node2D":
		current_level_instance.display_win(text)

func update_world_state(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta):
	if DedicatedServer.connected:
		players_connected = current_level_instance.get_node("YSort/OtherPlayers").get_child_count() + 1
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
					if current_level_instance.get_node("YSort/OtherPlayers").has_node(str(player)):
						var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
						current_level_instance.get_node("YSort/OtherPlayers/" + str(player)).move_player(new_position)
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
					if current_level_instance.get_node("YSort/OtherPlayers").has_node(str(player)):
						var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
						var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
						current_level_instance.get_node("YSort/OtherPlayers/" + str(player)).move_player(new_position)
