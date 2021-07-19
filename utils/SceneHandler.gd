extends Node

var level1 = preload("res://scenes/levels/TestLevel_1.tscn")
var player_spawn = preload("res://scenes/entities/player/PlayerTemplate.tscn")
var level_instance: Node2D
var last_world_state = 0

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
	level_instance.get_node("YSort/OtherPlayers/" + str(pid)).queue_free()

func update_world_state(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(get_tree().get_network_unique_id())
		for player in world_state.keys():
			if level_instance.get_node("YSort/OtherPlayers").has_node(str(player)):
				level_instance.get_node("YSort/OtherPlayers/" + str(player)).move_player(world_state[player]["P"])
			else:
				spawn_player(player, world_state[player]["P"])
