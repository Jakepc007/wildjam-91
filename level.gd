extends Node2D

@onready var player_scene = preload("res://player.tscn")
@onready var camera_scene = preload("res://camera.tscn")

@onready var spawn_position = $SpawnPosition
@onready var exit_position = $ExitPosition

@export var level_time_sec : float = 60

var _time_left : float :
	set(val) :
		if val > 0:
			_time_left = val
			Global.level_time_left_changed.emit(_time_left)
		else:
			_time_over = true
var _time_over : bool

func _ready():
	var player = player_scene.instantiate()
	add_child(player)
	player.position = spawn_position.position
	player.connect("InventoryUpdated", on_inventory_updated)

	var camera = camera_scene.instantiate()
	add_child(camera)
	camera.target = player
	connect_guards_caught_signal()
	start()

func connect_guards_caught_signal():
	for c in get_children():
		if not c is Guard:
			continue
		c = c as Guard
		c.player_caught.connect(on_player_caught)

func on_inventory_updated(inventory: Array):
	print(inventory)

func _process(delta: float) -> void:
	if not _time_over:
		update_time_left(delta)

func on_player_caught():
	print("player caught")

func start():
	_time_over = false
	_time_left = level_time_sec

func update_time_left(delta):
	_time_left -= delta
	if _time_left <= 0:
		pass

func on_game_over():
	# Show game over UI
	# halt guards so they don't spaz out
	# stop player input
	pass
