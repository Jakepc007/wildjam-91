class_name Level extends Node2D

const MIN_EXIT_DISTANCE = 50.0
const LEVEL_SUMMARY_SCENE = preload("res://Levels/level_summary.tscn")

@onready var player_scene = preload("res://player.tscn")
@onready var camera_scene = preload("res://camera.tscn")
@onready var game_over_scene = preload("res://menus/game_over.tscn")

@onready var spawn_position = $SpawnPosition
@onready var exit_position = $ExitPosition

@export var level_name : String = ""
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
	Global.required_value = required_value
	Global.exit_position = exit_position.position
	player = player_scene.instantiate()
	add_child(player)
	player.position = spawn_position.position
	if Global.inventory_ring:
		Global.inventory_ring.connect_to_player()
	player.connect("InventoryUpdated", on_inventory_updated)

	var camera = camera_scene.instantiate()
	add_child(camera)
	camera.target = player
	connect_guards_caught_signal(self)
	connect_cameras_caught_signal(self)
	start()

func connect_guards_caught_signal(node : Node):
	for c in node.get_children():
		if not c is Guard:
			connect_guards_caught_signal(c)
			continue
		c = c as Guard
		c.player_caught.connect(on_player_caught)

func connect_cameras_caught_signal(node : Node):
	for c in node.get_children():
		if not c is SecurityCamera:
			connect_cameras_caught_signal(c)
			continue
		c = c as SecurityCamera
		c.player_found.connect(on_player_caught)

func on_inventory_updated(inventory: Array):
	print(inventory)

func _process(delta: float) -> void:
	if not _time_over:
		update_time_left(delta)

	if player.position.distance_to(exit_position.position) < MIN_EXIT_DISTANCE:
		if not in_transition and Global.inventory_ring.condition_fulfilled:
			in_transition = true
			_go_to_level_summary()
			return

func _go_to_level_summary():
	var total_value := 0
	var item_list: Array[ItemStats.Item] = []
	for pickup in player.inventory:
		var stats = ItemStats.get_item(pickup.item)
		total_value += int(stats.value)
		item_list.append(pickup.item)
	Global.level_stats = {
		"level_name": level_name,
		"time_left": _time_left,
		"value": total_value,
		"items": item_list,
		"next_scene": next_scene,
	}
	Global.scene_manager.switch_scene_with_fade(LEVEL_SUMMARY_SCENE)

func on_player_caught():
	if Global.audio_manager:
		Global.audio_manager.pause_current_track()
	if Global.scene_manager:
		Global.scene_manager.switch_scene_with_fade(game_over_scene)

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
