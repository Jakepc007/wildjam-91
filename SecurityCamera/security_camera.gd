extends Node2D

@export var line_of_sight_detector : LineOfSightDetector
@export var animation_player : AnimationPlayer
@export var alerted_sprite : Sprite2D

@export var time_to_alert : float = 0.3 # the time it takes for a player being seen to cause an alarm

@export var _DEBUG_PLAYER : Node2D

var _player_spotted : bool
var _player_spotted_time : float # the time at which the player was spotted

signal player_found()

#@export_range(0, 360, 0.1, "radians_as_degrees") var max_rotation : float = 20

func _ready() -> void:
	animation_player.play("sweep")

func _physics_process(delta: float) -> void:
	var player_spotted_this_frame : bool = line_of_sight_detector.player_detected(_DEBUG_PLAYER.global_position)
	if not _player_spotted and player_spotted_this_frame:
		_player_spotted_time = Time.get_unix_time_from_system()
	_player_spotted = player_spotted_this_frame
	if _player_spotted and Time.get_unix_time_from_system() - _player_spotted_time > time_to_alert:
		player_found.emit()
		alerted_sprite.visible = true
	else:
		alerted_sprite.visible = false
