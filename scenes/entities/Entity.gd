extends KinematicBody2D
class_name Entity

onready var Constants: Node = get_node("/root/Constants")

var previous_states: Array = []
var state_machine: EntityFSM
var animation_player: AnimationPlayer

onready var gravity: int = Constants.GRAVITY
var speed: int

func set_state_machine(sm: EntityFSM) -> void:
	state_machine = sm

func set_animation_player(ap: AnimationPlayer) -> void:
	animation_player = ap
