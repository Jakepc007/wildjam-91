class_name Player extends CharacterBody2D

const VELOCITY_ACC := 50.

@onready var pickup_notice: Label = $PickupNotice
@onready var pickup_detection_area: Area2D = $PickupDetectionArea

var overlapping_pickups: Array = []
var inventory: Array = []
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

	# if overlapping_pickups.size() > 0:

	# 	closest_pickup.highlight()
	# 	pickup_notice.show()
	# else:
	# 	if closest_pickup:
	# 		closest_pickup.unhighlight()
	# 	pickup_notice.hide()
	# 	closest_pickup = null

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		if closest_pickup:
			inventory.append(closest_pickup)
			overlapping_pickups.erase(closest_pickup)
			# TODO: handle pickup logic within pickup.gd
			closest_pickup.queue_free()

func _ready():
	pickup_detection_area.connect("area_entered", on_pickup_area_entered)
	pickup_detection_area.connect("area_exited", on_pickup_area_exited)

func on_pickup_area_entered(area: Area2D):
	overlapping_pickups.append(area)

func on_pickup_area_exited(area: Area2D):
	overlapping_pickups.erase(area)
