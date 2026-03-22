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
	level_complete_label.text = "Level %s Complete!" % level_name if level_name != "" else "Level Complete!"
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	time_left_label.text = "%02d:%02d" % [minutes, seconds]
	value_label.text = "$" + format_number(value)
	await get_tree().create_timer(0.5).timeout
	for item in items:
		var stats = ItemStats.get_item(item)
		if not stats:
			continue
		var tex_rect := TextureRect.new()
		tex_rect.texture = load(stats.image_path)
		tex_rect.custom_minimum_size = Vector2(64, 64)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.tooltip_text = stats.item_name
		tex_rect.scale = Vector2.ZERO
		items_container.add_child(tex_rect)
		tex_rect.pivot_offset = tex_rect.size / 2.0
		var tween := create_tween()
		tween.tween_property(tex_rect, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		await get_tree().create_timer(0.1).timeout

func format_number(n: int) -> String:
	var s = str(n)
	var result = ""
	for i in s.length():
		if i > 0 and (s.length() - i) % 3 == 0:
			result += ","
		result += s[i]
	return result

func _on_continue_pressed():
	var next_scene = Global.level_stats.get("next_scene", null)
	if next_scene:
		Global.scene_manager.switch_scene_with_fade(next_scene)
