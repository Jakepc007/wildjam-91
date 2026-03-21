class_name Player extends CharacterBody2D

# TODO: JKM this needs to be an actual representation of inventory items through some class or something
signal InventoryUpdated(inventory: Array)
signal add_pickup(item) # sent out so the inventory ring can listen, wherever it is

const VELOCITY_ACC := 50.
const MAX_INVENTORY_CAPACITY := 10.

@onready var pickup_notice: Label = $PickupNotice
@onready var pickup_detection_area: Area2D = $PickupDetectionArea
@onready var inventory_floater: Label = $InventoryFloater

@export var inventory_ring: InventoryRing = null

var overlapping_pickups: Array = []
var inventory: Array = []
var current_inventory_weight := 0.0

static var closest_pickup: Pickup = null

func _physics_process(delta: float):
	if Input.is_action_pressed("left"):
		velocity.x -= VELOCITY_ACC
	if Input.is_action_pressed("right"):
		velocity.x += VELOCITY_ACC
	if Input.is_action_pressed("up"):
		velocity.y -= VELOCITY_ACC
	if Input.is_action_pressed("down"):
		velocity.y += VELOCITY_ACC

	move_and_slide()
	velocity *= 0.9

func _process(delta: float):
	if overlapping_pickups.size() > 0:
		closest_pickup = overlapping_pickups[0]
		for pickup in overlapping_pickups:
			if pickup.global_position.distance_to(global_position) < closest_pickup.global_position.distance_to(global_position):
				closest_pickup = pickup
	else:
		closest_pickup = null

	if closest_pickup:
		pickup_notice.show()
	else:
		pickup_notice.hide()

	# TODO: DELETE when inventory is figured out
	var output = ""
	for pickup in inventory:
		var stats = ItemStats.get_item(pickup.item)
		output += str(stats.value) + "v " + str(stats.weight) + "w\n"
	inventory_floater.text = output

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		if closest_pickup:
			var closest_stats = ItemStats.get_item(closest_pickup.item)
			if current_inventory_weight + closest_stats.weight <= MAX_INVENTORY_CAPACITY:
				var item_type = closest_pickup.item
				inventory.append(closest_pickup.duplicate())
				overlapping_pickups.erase(closest_pickup)
				# TODO: handle pickup logic within pickup.gd
				closest_pickup.queue_free()
				current_inventory_weight += closest_stats.weight
				add_pickup.emit(item_type)
			else:
				print("you're full")

func _ready():
	Global.player = self
	pickup_detection_area.connect("area_entered", on_pickup_area_entered)
	pickup_detection_area.connect("area_exited", on_pickup_area_exited)

func on_pickup_area_entered(area: Area2D):
	overlapping_pickups.append(area)

func on_pickup_area_exited(area: Area2D):
	overlapping_pickups.erase(area)
