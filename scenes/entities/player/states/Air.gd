extends EntityState

func enter(player: KinematicBody2D) -> void:
	.enter(player)

func run(player: KinematicBody2D) -> String:
	if player.is_on_floor():
		return "idle"
	if player.h_input:
		player.velocity.x = player.speed * player.h_input
	return ""
