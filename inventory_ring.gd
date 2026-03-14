extends Node2D

const MIN_PICKUP_HOVER_DISTANCE = 32.

var acc := 0.
var pickups := []
var closest_pickup_to_mouse = null

func _ready():
	for child in get_children():
		pickups.append(child)

func _process(delta: float):
	acc += delta * 10.
	apply_pickup_forces(delta)
	queue_redraw()
	var viewport_mouse_position = get_viewport().get_mouse_position() - Vector2.ONE * 320.
	for pickup in pickups:
		var dist = pickup.position.distance_to(viewport_mouse_position)

		if closest_pickup_to_mouse == null:
			closest_pickup_to_mouse = pickup
		else:
			var closest_dist = closest_pickup_to_mouse.position.distance_to(viewport_mouse_position)
			if dist < closest_dist:
				closest_pickup_to_mouse = pickup

		if closest_pickup_to_mouse == pickup:
			if dist < MIN_PICKUP_HOVER_DISTANCE:
				pickup.modulate.a = 0.8
			else:
				pickup.modulate.a = 1.
		else:
			pickup.modulate.a = 1.

	if Input.is_action_pressed("inventory"):
		modulate.a = min(modulate.a + delta * 10., 1.)
	else:
		modulate.a = max(modulate.a - delta * 5., 0.)


func _draw():
	draw_arc(Vector2.ZERO, 96. * 2., 0., acc, 17, Color.WHITE, 8.)

func apply_pickup_forces(delta: float):
	# apply gravity towards the center
	for pickup in pickups:
		pickup.position = lerp(pickup.position, Vector2.ZERO, delta * 1.)

	# move around in a circular random motion
	# for pickup in pickups:
	# 	pickup.position.x += sin(acc) * 0.1

	# apply boid force to push them apart
	for pickup in pickups:
		for other in pickups:
			if pickup != other:
				var dist = pickup.position.distance_to(other.position)
				var force = pickup.position - other.position
				force /= dist * dist
				pickup.position += force * delta * 1000.

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				for pickup in pickups:
					var dist = pickup.position.distance_to(get_viewport().get_mouse_position() - Vector2.ONE * 320.)
					if dist < MIN_PICKUP_HOVER_DISTANCE:
						pickups.erase(pickup)
						pickup.queue_free()
