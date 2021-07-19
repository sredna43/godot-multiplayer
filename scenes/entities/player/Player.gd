extends Entity
class_name Player

var h_input: float = 0
onready var jump_power = Constants.PLAYER_JUMP_POWER
onready var air_resistance = Constants.PLAYER_AIR_RESISTANCE
onready var air_accel = Constants.PLAYER_AIR_ACCELERATION
onready var jump_cancel = Constants.PLAYER_JUMP_CANCEL

onready var l_floor_feeler = $Feelers/LFloorFeeler
onready var r_floor_feeler = $Feelers/RFloorFeeler
onready var jump_timer = $Timers/JumpTimer
var jumping: bool = false setget , _get_jumping

var player_state: Dictionary = {}

func _get_jumping() -> bool:
	return not jump_timer.is_stopped()

func _ready() -> void:
	state_machine = $States
	animation_player = $Sprite/AnimationPlayer
	state_machine.init(self)
	speed = Constants.PLAYER_SPEED
	
func _handle_inputs() -> void:
	h_input = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	if Input.is_action_just_pressed("jump"):
		jump_timer.start()
	
func on_floor() -> bool:
	return is_on_floor() or l_floor_feeler.is_colliding() or r_floor_feeler.is_colliding()
	
func define_player_state() -> void:
	player_state = {"T": OS.get_system_time_msecs(), "P": get_global_position()}
	Server.send_player_state(player_state)
	
func _physics_process(delta) -> void:
	_handle_inputs()
	._physics_process(delta)
	define_player_state()
