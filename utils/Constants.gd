extends Node

var ip = "161.35.124.177"
var lobby_server = "http://127.0.0.1:5000"

var GRAVITY: int = 10
var TERMINAL_VELOCITY: int = 1000
var PLAYER_SPEED: int = 200
var PLAYER_JUMP_POWER: int = -300
var PLAYER_AIR_RESISTANCE: float = 0.03 # smaller number = less resistance
var PLAYER_AIR_ACCELERATION: float = 10
var PLAYER_JUMP_CANCEL: float = 0.3 # larger number = quicker cancel
var PLAYER_FRICTION: float = 0.2
