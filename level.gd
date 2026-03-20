class_name Level extends Node2D

const MIN_EXIT_DISTANCE = 50.0

@onready var player_scene = preload("res://player.tscn")
@onready var camera_scene = preload("res://camera.tscn")

@onready var spawn_position = $SpawnPosition
@onready var exit_position = $ExitPosition

@export var level_time_sec : float = 60
@export var required_value : int = 10
@export var next_scene : PackedScene = null

var player: Player
var in_transition : bool = false

var _time_left : float :
	set(val) :
		if val > 0:
			_time_left = val
			Global.level_time_left_changed.emit(_time_left)
		else:
			_time_over = true
var _time_over : bool

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	player = player_scene.instantiate()
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

	print(player.position.distance_to(exit_position.position))
	if player.position.distance_to(exit_position.position) < MIN_EXIT_DISTANCE:
		if next_scene && not in_transition:
			print("transitioning to next scene")
			in_transition = true
			Global.scene_manager.switch_scene_with_fade(next_scene)
			return

func on_player_caught():
	print("player caught")

func start():
	_time_over = false
	_time_left = level_time_sec
	if Global.audio_manager:
		Global.audio_manager.play_track(AudioManager.Track.LEVEL, 0.1)

func update_time_left(delta):
	_time_left -= delta
	if _time_left <= 0:
		pass

func on_game_over():
	# Show game over UI
	# halt guards so they don't spaz out
	# stop player input
	pass
