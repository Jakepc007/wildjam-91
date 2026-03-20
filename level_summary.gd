extends Node2D

@onready var camera: Camera2D = $Camera2D

func _process(delta: float) -> void:
	camera.position.x += delta * 100.
