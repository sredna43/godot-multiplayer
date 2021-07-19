extends KinematicBody2D
class_name Entity

onready var Constants: Node = get_node("/root/Constants")

var previous_states: Array = []
var state_machine: EntityFSM setget _set_state_machine
var animation_player: AnimationPlayer setget _set_animation_player
onready var gravity: int = Constants.GRAVITY
var velocity: Vector2 = Vector2()
onready var speed: int setget _set_speed

func _set_state_machine(sm: EntityFSM) -> void:
	state_machine = sm

func _set_animation_player(ap: AnimationPlayer) -> void:
	animation_player = ap
	
func _set_speed(sp: int) -> void:
	speed = sp

func apply_gravity() -> void:
	velocity.y = clamp(velocity.y + gravity, -Constants.TERMINAL_VELOCITY, Constants.TERMINAL_VELOCITY)

func move() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)

func _physics_process(_delta) -> void:
	move()
	apply_gravity()
	state_machine.run()
