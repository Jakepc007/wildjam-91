extends Node

var scene_manager : SceneManager
var inventory_ring : InventoryRing
var player : Player :
	set(x):
		player = x
		player_ready.emit()

signal player_ready()
signal level_time_left_changed(time_left : float)
var audio_manager : AudioManager
var _last_level : PackedScene
var level_stats : Dictionary = {}
var required_value : int = 0
var exit_position : Vector2
