extends Node2D
class_name SecurityCamera

@export var line_of_sight_detector : LineOfSightDetector
@export var animation_player : AnimationPlayer
@export var alerted_sprite : Sprite2D
@onready var point_light_2d: PointLight2D = $Rotation/PointLight2D
@onready var alert: AudioStreamPlayer = $Alert
@export var time_to_alert : float = 0.3 # the time it takes for a player being seen to cause an alarm

@export var _DEBUG_PLAYER : Node2D

var _player_spotted : bool
var _player_found : bool
var _player_spotted_time : float # the time at which the player was spotted

signal player_found(camera : SecurityCamera, location_found : Vector2)


func _ready() -> void:
	if Global.scene_manager and Global.scene_manager.animation_player: ## if in full game, wait for any screen transition effects to end to turn on light
		point_light_2d.visible = false
		Global.scene_manager.animation_player.animation_finished.connect((func(_y,x):x.visible = true).bind(point_light_2d),Object.ConnectFlags.CONNECT_ONE_SHOT)
	else: # just turn it on otherwise
		point_light_2d.visible = true
	animation_player.play("sweep")

func _physics_process(delta: float) -> void:
	var player_spotted_this_frame : bool = line_of_sight_detector.player_detected(_DEBUG_PLAYER.global_position)
	if not _player_spotted and player_spotted_this_frame:
		_player_spotted_time = Time.get_unix_time_from_system()
	_player_spotted = player_spotted_this_frame
	if _player_spotted and Time.get_unix_time_from_system() - _player_spotted_time > time_to_alert:
		if not _player_found:
			player_found.emit(self, line_of_sight_detector.last_player_location)
			alert.play(0)
			alerted_sprite.visible = true
			_player_found = true
	else:
		_player_found = false
		alerted_sprite.visible = false
