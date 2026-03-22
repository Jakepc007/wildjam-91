class_name InventoryRing extends Node2D

@onready var inventory_pickup_scene := preload("res://inventory_pickup.tscn")
@onready var pickup_scene := preload("res://pickup.tscn")
@onready var exit_door_sprite := $ExitDoorSprite
const ICON_MONEY := preload("res://assets/icons/money.png")
const ICON_WEIGHT := preload("res://assets/icons/weight.png")
@export var player: Player = null

const MIN_PICKUP_HOVER_DISTANCE = 32.

var acc := 0.
var ring_alpha := 0.0
var pickups := []
var pickup_item_types := {}  # instance_id -> ItemStats.Item
var closest_pickup_to_mouse = null
var grabbed_pickup = null
var hovered_pickup = null

var dropped_pickups := []

var required_value: int = 0
var condition_fulfilled: bool = false
var total_inventory_value: int = 0
var total_inventory_weight: float = 0.0

func _recalculate_condition() -> void:
	total_inventory_value = 0
	total_inventory_weight = 0.0
	for item_type in pickup_item_types.values():
		total_inventory_value += int(ItemStats.get_item(item_type).value)
		total_inventory_weight += ItemStats.get_item(item_type).weight
	condition_fulfilled = total_inventory_value >= required_value

func _ready():
	Global.inventory_ring = self
	modulate.a = 1.0

func connect_to_player():
	if is_instance_valid(player):
		player.add_pickup.disconnect(add_pickup)
	for pickup in pickups:
		pickup.queue_free()
	pickups.clear()
	pickup_item_types.clear()
	for pickup in dropped_pickups:
		if is_instance_valid(pickup):
			pickup.queue_free()
	dropped_pickups.clear()
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
	#print("condition_fulfilled? %s" % condition_fulfilled)
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
				hovered_pickup = pickup
			else:
				pickup.modulate.a = 1.
				if hovered_pickup == pickup:
					hovered_pickup = null
		else:
			pickup.modulate.a = 1.

	if Input.is_action_pressed("inventory"):
		acc = min(acc + delta * 50., TAU)
		ring_alpha = min(ring_alpha + delta * 10., 1.)
	else:
		acc = max(acc - delta * 10., 0.)
		ring_alpha = max(ring_alpha - delta * 5., 0.)
	for pickup in pickups:
		pickup.modulate.a = ring_alpha

	if Global.exit_position:
		exit_door_sprite.visible = condition_fulfilled
		if condition_fulfilled:
			var to_exit := Global.exit_position - player.position
			exit_door_sprite.position = to_exit.normalized() * min(to_exit.length(), 240.)
		#print("global.exit position =", Global.exit_position)

func _draw():
	draw_circle(Vector2.ZERO, 140. + acc * 10., Color(1., 1., 1., 0.2 * ring_alpha))
	draw_arc(Vector2.ZERO, 142. + acc * 10., 0., TAU, 53, Color(1., 1., 1., ring_alpha), 8.)
	var bar_alpha: float = lerp(0.35, 1.0, ring_alpha)
	# value requirement (left)
	draw_arc(Vector2.ZERO, 120. + acc * 10., PI/2 + 0.6, 3*PI/2 - 0.6, 53, Color(0.1, 0.1, 0.1, bar_alpha), 16.)
	var value_ratio = clamp(float(total_inventory_value) / float(required_value), 0.0, 1.0) if required_value > 0 else 0.0
	var arc_offset = 1.9 * (1.0 - value_ratio)
	draw_arc(Vector2.ZERO, 121. + acc * 10., PI/2 + 0.62, 3*PI/2 - 0.62 - arc_offset, 53, Color(1.0, 0.1, 0.1, bar_alpha), 10.)
	# weight capacity (right)
	draw_arc(Vector2.ZERO, 120. + acc * 10., -PI/2 + 0.6, PI/2 - 0.6, 53, Color(0.1, 0.1, 0.1, bar_alpha), 16.)
	var max_weight := float(Player.MAX_INVENTORY_CAPACITY)
	var weight_ratio = clamp(total_inventory_weight / max_weight, 0.0, 1.0)
	var weight_offset = 1.9 * (1.0 - weight_ratio)
	draw_arc(Vector2.ZERO, 121. + acc * 10., -PI/2 + 0.62, PI/2 - 0.62 - weight_offset, 53, Color(0.2, 0.6, 1.0, bar_alpha), 10.)

	var icon_size := Vector2(90, 90)
	var icon_color := Color(1., 1., 1., bar_alpha)
	draw_texture_rect(ICON_MONEY, Rect2(Vector2(-120. - acc * 10., -40.), icon_size), false, icon_color)
	draw_texture_rect(ICON_WEIGHT, Rect2(Vector2(26. + acc * 10., -40.), icon_size), false, icon_color)

	if condition_fulfilled:
		var font := ThemeDB.fallback_font
		var text := "Head for the exit!"
		var font_size := 32
		var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, Vector2(-text_width / 2.0, -240.), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1., 1., 1., 1.))

	if hovered_pickup and ring_alpha > 0.0:
		var item_type = pickup_item_types.get(hovered_pickup.get_instance_id())
		if item_type != null:
			var stats = ItemStats.get_item(item_type)
			if stats:
				var font := ThemeDB.fallback_font
				var fs := 18
				var icon_s := Vector2(fs, fs)
				var padding := Vector2(10., 8.)
				var line_gap := 6.
				var row_h := float(fs) + line_gap
				var tooltip_h := padding.y * 2. + row_h * 2. - line_gap
				var tooltip_w := 160.
				var tip_pos: Vector2 = hovered_pickup.position + Vector2(-tooltip_w / 2., -80.)
				draw_rect(Rect2(tip_pos, Vector2(tooltip_w, tooltip_h)), Color(0., 0., 0., 0.75 * ring_alpha), true, 0.)
				# weight row
				var row1 := tip_pos + Vector2(padding.x, padding.y + fs)
				draw_texture_rect(ICON_WEIGHT, Rect2(row1 - Vector2(0., fs), icon_s), false, Color(1., 1., 1., ring_alpha))
				draw_string(font, row1 + Vector2(icon_s.x + 4., 0.), "%s lbs" % stats.weight, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1., 1., 1., ring_alpha))
				# value row
				var row2 := row1 + Vector2(0., row_h)
				draw_texture_rect(ICON_MONEY, Rect2(row2 - Vector2(0., fs), icon_s), false, Color(1., 1., 1., ring_alpha))
				draw_string(font, row2 + Vector2(icon_s.x + 4., 0.), "$%s" % stats.value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1., 1., 1., ring_alpha))

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
				dropped_pickups.append(pickup)

		grabbed_pickup = null
