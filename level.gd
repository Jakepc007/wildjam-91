extends Node2D

@onready var player_scene = preload("res://player.tscn")
@onready var camera_scene = preload("res://camera.tscn")

@onready var spawn_position = $SpawnPosition
@onready var exit_position = $ExitPosition

func _ready():
	var player = player_scene.instantiate()
	add_child(player)
	player.position = spawn_position.position
	player.connect("InventoryUpdated", on_inventory_updated)

	var camera = camera_scene.instantiate()
	add_child(camera)
	camera.target = player

func on_inventory_updated(inventory: Array):
	print(inventory)
