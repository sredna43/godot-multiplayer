extends Node

var level1 = preload("res://scenes/levels/TestLevel_1.tscn")
var player_spawn = preload("res://scenes/entities/player/PlayerTemplate.tscn")
var level_instance: Node2D
var last_world_state = 0
var world_state_buffer: Array = []
var interpolation_offset = 100

func _ready():
	level_instance = level1.instance()
	add_child(level_instance)

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
	var render_time = OS.get_system_time_msecs() - interpolation_offset
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
