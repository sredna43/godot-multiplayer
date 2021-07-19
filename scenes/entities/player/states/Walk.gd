extends EntityState

func run(player: KinematicBody2D) -> String:
	if player.h_input:
		player.velocity.x = player.speed * player.h_input
	if player.h_input == 0:
		return "idle"
	if player.jumping:
		return "jump"
	return ""
