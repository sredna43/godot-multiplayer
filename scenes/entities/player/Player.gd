extends Entity
class_name Player

var velocity: Vector2 = Vector2()

func _ready() -> void:
	set_state_machine($States)
	set_animation_player($Sprite/AnimationPlayer)
	state_machine.init(self)
	speed = Constants.PLAYER_SPEED
	
func apply_gravity() -> void:
	velocity.y += gravity
