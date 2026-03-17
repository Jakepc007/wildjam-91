class_name InventoryRing extends Node2D

@onready var inventory_pickup_scene := preload("res://inventory_pickup.tscn")
@onready var pickup_scene := preload("res://pickup.tscn")
@export var player: Player = null

const MIN_PICKUP_HOVER_DISTANCE = 32.

var acc := 0.
var pickups := []
var closest_pickup_to_mouse = null
var grabbed_pickup = null

func _ready():
	for child in get_children():
		pickups.append(child)

# TODO: JKM - tie the item properties to the inventory pickup
func add_pickup(item):
	var inventory_pickup = inventory_pickup_scene.instantiate()
	# inventory_pickup.position = item.position
	inventory_pickup.position = Vector2(
		randf_range(-50, 50),
		randf_range(-50, 50)
	)
	add_child(inventory_pickup)
	pickups.append(inventory_pickup)

func _process(delta: float):
	apply_pickup_forces(delta)
	queue_redraw()
	var viewport_mouse_position = get_viewport().get_mouse_position() - Vector2.ONE * 320.
	for pickup in pickups:
		if pickup == grabbed_pickup:
			pickup.position = viewport_mouse_position
			if pickup.position.length() > 200:
				pickup.modulate.a = 0.2
			else:
				pickup.modulate.a = 1.
			continue
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
		acc = min(acc + delta * 50., TAU)
		modulate.a = min(modulate.a + delta * 10., 1.)
	else:
		acc = max(acc - delta * 10., 0.)
		modulate.a = max(modulate.a - delta * 5., 0.)

func _draw():
	draw_circle(Vector2.ZERO, 140. + acc * 10., Color(1., 1., 1., 0.2))
	draw_arc(Vector2.ZERO, 142. + acc * 10., 0., TAU, 53, Color.WHITE, 8.)

func apply_pickup_forces(delta: float):
	# apply gravity towards the center
	for pickup in pickups:
		if pickup == grabbed_pickup:
			continue
		pickup.position = lerp(pickup.position, Vector2.ZERO, delta * 1.)

	# move around in a circular random motion
	# for pickup in pickups:
	# 	pickup.position.x += sin(acc) * 0.1

	# apply boid force to push them apart
	for pickup in pickups:
		if pickup == grabbed_pickup:
			continue
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
						grabbed_pickup = pickup
						break
	# on release, drop the pickup
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if grabbed_pickup:
			if grabbed_pickup.position.length() > 200.:
				# remove the pickup from the inventory of the player and the pickups array
				player.inventory.erase(grabbed_pickup)
				pickups.erase(grabbed_pickup)
				grabbed_pickup.queue_free()
				var pickup = pickup_scene.instantiate()
				pickup.position = player.position + Vector2(
					randf_range(-20, 20),
					randf_range(-20, 20)
				)
				get_tree().root.add_child(pickup)

		grabbed_pickup = null
