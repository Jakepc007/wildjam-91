extends Node

var scene_manager : SceneManager
var player : Player :
	set(x):
		player = x
		player_ready.emit()

signal player_ready()
