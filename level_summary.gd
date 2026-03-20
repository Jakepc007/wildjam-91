extends Node2D

@onready var camera: Camera2D = $Camera2D

@onready var level_complete_label: Label = %LevelCompleteLabel
@onready var time_left_label: Label = %TimeLeftLabel
@onready var value_label: Label = %ValueLabel
@onready var items_container: HFlowContainer = %ItemsContainer
@onready var continue_button: Button = $CanvasLayer/Button

func _ready():
	var stats = Global.level_stats
	populate_stats(
		stats.get("level_name", ""),
		stats.get("time_left", 0.0),
		stats.get("value", 0),
		stats.get("items", [])
	)
	continue_button.pressed.connect(_on_continue_pressed)

func _process(delta: float) -> void:
	camera.position.x += delta * 100.

func populate_stats(level_name: String, time_left: float, value: int, items: Array):
	level_complete_label.text = level_name if level_name != "" else "Level Complete!"
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	time_left_label.text = "%02d:%02d" % [minutes, seconds]
	value_label.text = str(value)

func _on_continue_pressed():
	var next_scene = Global.level_stats.get("next_scene", null)
	if next_scene:
		Global.scene_manager.switch_scene_with_fade(next_scene)
