extends Camera2D

const CAMERA_LERP_SPEED = 100.0

@export var target : Node2D

func _process(delta: float):
	if target:
		# position = lerp(position, target.position, delta * CAMERA_LERP_SPEED)
		global_position = target.global_position
		#print(global_position)
