extends EntityState

func enter(player: KinematicBody2D) -> void:
	.enter(player)

func run(player: KinematicBody2D) -> String:
	player.previous_states.clear()
	if player.h_input != 0:
		return "walk"
	if not player.on_floor():
		return "air"
	if player.jumping:
		return "jump"
	player.velocity.x = lerp(player.velocity.x, 0, player.friction)
	return ""
