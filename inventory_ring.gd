class_name InventoryRing extends Node2D

@onready var inventory_pickup_scene := preload("res://inventory_pickup.tscn")
@onready var pickup_scene := preload("res://pickup.tscn")
@onready var exit_door_sprite := $ExitDoorSprite
@export var player: Player = null

const MIN_PICKUP_HOVER_DISTANCE = 32.

var acc := 0.
var pickups := []
var pickup_item_types := {}  # instance_id -> ItemStats.Item
var closest_pickup_to_mouse = null
var grabbed_pickup = null

var required_value: int = 0
var condition_fulfilled: bool = false
var total_inventory_value: int = 0

func _recalculate_condition() -> void:
	total_inventory_value = 0
	for item_type in pickup_item_types.values():
		total_inventory_value += int(ItemStats.get_item(item_type).value)
	condition_fulfilled = total_inventory_value >= required_value

func _ready():
	Global.inventory_ring = self

func connect_to_player():
	if is_instance_valid(player):
		player.add_pickup.disconnect(add_pickup)
	for pickup in pickups:
		pickup.queue_free()
	pickups.clear()
	pickup_item_types.clear()
	Global.player.add_pickup.connect(add_pickup)
	player = Global.player
	required_value = Global.required_value
	_recalculate_condition()

# TODO: JKM - tie the item properties to the inventory pickup
func add_pickup(item):
	var inventory_pickup = inventory_pickup_scene.instantiate()
	# inventory_pickup.position = item.position
	inventory_pickup.position = Vector2(
		randf_range(-50, 50),
		randf_range(-50, 50)
	)
	add_child(inventory_pickup)
	inventory_pickup.set_image(ItemStats.get_item(item).image_path)
	pickup_item_types[inventory_pickup.get_instance_id()] = item
	pickups.append(inventory_pickup)
	_recalculate_condition()

func _process(delta: float):
	print("condition_fulfilled? %s" % condition_fulfilled)
	apply_pickup_forces(delta)
	queue_redraw()
	#var viewport_mouse_position = get_viewport().get_mouse_position() - (Vector2(480, 320))
	var local_mouse_position = get_local_mouse_position()
	for pickup in pickups:
		if pickup == grabbed_pickup:
			pickup.position = local_mouse_position
			if pickup.position.length() > 200:
				pickup.modulate.a = 0.2
			else:
				pickup.modulate.a = 1.
			continue
		var dist = pickup.position.distance_to(local_mouse_position)

		if closest_pickup_to_mouse == null:
			closest_pickup_to_mouse = pickup
		else:
			var closest_dist = closest_pickup_to_mouse.position.distance_to(local_mouse_position)
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

	if Global.exit_position:
		var to_exit := Global.exit_position - player.position
		exit_door_sprite.position = to_exit.normalized() * min(to_exit.length(), 240.)
		print("global.exit position =", Global.exit_position)

func _draw():
	draw_circle(Vector2.ZERO, 140. + acc * 10., Color(1., 1., 1., 0.2))
	draw_arc(Vector2.ZERO, 142. + acc * 10., 0., TAU, 53, Color.WHITE, 8.)
	# value requirement
	draw_arc(Vector2.ZERO, 120. + acc * 10., PI + 0.6, TAU - 0.6, 53, Color(0.1, 0.1, 0.1), 16.)
	var value_ratio = clamp(float(total_inventory_value) / float(required_value), 0.0, 1.0) if required_value > 0 else 0.0
	var arc_offset = 1.9 * (1.0 - value_ratio)
	draw_arc(Vector2.ZERO, 121. + acc * 10., PI + 0.62, TAU - 0.62 - arc_offset, 53, Color(1.0, 0.1, 0.1), 10.)
	# draw_arc(Vector2.ZERO, 132. + acc * 10., PI + 0.3, TAU - 0.3, 53, Color.RED, 8.)

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
					var dist = pickup.position.distance_to(get_local_mouse_position())
					if dist < MIN_PICKUP_HOVER_DISTANCE:
						grabbed_pickup = pickup
						break
	# on release, drop the pickup
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if grabbed_pickup:
			if grabbed_pickup.position.length() > 200.:
				var item_type = pickup_item_types.get(grabbed_pickup.get_instance_id())
				pickup_item_types.erase(grabbed_pickup.get_instance_id())
				# remove the matching item from the player's inventory
				for i in range(player.inventory.size()):
					if player.inventory[i].get("item") == item_type:
						player.current_inventory_weight -= ItemStats.get_item(item_type).weight
						player.inventory.remove_at(i)
						break
				pickups.erase(grabbed_pickup)
				grabbed_pickup.queue_free()
				_recalculate_condition()
				var pickup = pickup_scene.instantiate()
				pickup.item = item_type
				pickup.position = player.position + Vector2(
					randf_range(-20, 20),
					randf_range(-20, 20)
				)
				get_tree().root.add_child(pickup)

		grabbed_pickup = null
