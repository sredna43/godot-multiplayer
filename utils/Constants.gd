extends Node

var ip = ""
var lobby_server = "http://:56900"

var GRAVITY: int = 10
var TERMINAL_VELOCITY: int = 1000
var PLAYER_SPEED: int = 170
var PLAYER_JUMP_POWER: int = -400
var PLAYER_AIR_RESISTANCE: float = 0.03 # smaller number = less resistance
var PLAYER_AIR_ACCELERATION: float = 10
var PLAYER_JUMP_CANCEL: float = 0.3 # larger number = quicker cancel
var PLAYER_FRICTION: float = 0.2
