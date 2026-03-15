extends Node2D
class_name LineOfSightDetector

@export var ray_cast : RayCast2D
@export var player_detection_cone : Area2D


func player_detected(player_global_position : Vector2) -> bool:
	return player_is_in_cone() and player_in_line_of_sight(player_global_position)

func player_is_in_cone() -> bool :
	return player_detection_cone.get_overlapping_bodies().size() > 0

func player_in_line_of_sight(player_global_position) -> bool :
	ray_cast.target_position = ray_cast.to_local(player_global_position)
	var body := ray_cast.get_collider()
	if body: # raycast hit something
		if not body is CollisionObject2D:
			return false
		return body.collision_layer & 2
	return false
