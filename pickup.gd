class_name Pickup extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

const HIGHLIGHT_SPEED = 5.

# TODO: not so elegant
# var highlighted := false

func _process(delta: float):
	if Player.closest_pickup == self:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.35, delta * HIGHLIGHT_SPEED * 2.)
	else:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.25, delta * HIGHLIGHT_SPEED)

# func highlight():
# 	highlighted = true
# 	print("highlighted")
# 	sprite.scale = Vector2(0.5, 0.5)

# func unhighlight():
# 	highlighted = false
# 	sprite.scale = Vector2(0.25, 0.25)
