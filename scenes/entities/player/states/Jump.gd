extends EntityState

func enter(player: KinematicBody2D) -> void:
	.enter(player)
	
func run(player: KinematicBody2D) -> String:
	player.velocity.y = player.jump_power
	return "air"
