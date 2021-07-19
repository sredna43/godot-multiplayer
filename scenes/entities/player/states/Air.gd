extends EntityState

func enter(player: KinematicBody2D) -> void:
	.enter(player)

func run(player: KinematicBody2D) -> String:
	if player.on_floor():
		return "idle"
	if player.h_input:
		player.velocity.x = clamp(player.velocity.x + player.air_accel * player.h_input, -player.speed, player.speed)
	if not player.h_input:
		player.velocity.x = lerp(player.velocity.x, 0, player.air_resistance)
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y = lerp(player.velocity.y, 0, player.jump_cancel)
	return ""
