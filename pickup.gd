class_name Pickup extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var item: ItemStats.Item
const HIGHLIGHT_SPEED = 5.

func _process(delta: float):
	if Player.closest_pickup == self:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.35, delta * HIGHLIGHT_SPEED * 2.)
	else:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.25, delta * HIGHLIGHT_SPEED)
