extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var level_complete_label: Label = %LevelCompleteLabel
@onready var time_left_label: Label = %TimeLeftLabel
@onready var value_label: Label = %ValueLabel
@onready var items_container: HFlowContainer = %ItemsContainer
@onready var continue_button: Button = $CanvasLayer/Button

func _ready():
	var stats := Global.level_stats
	var level_name: String = stats.get("level_name", "")
	var time_left: float = stats.get("time_left", 0.0)
	var items: Array = stats.get("items", [])

	level_complete_label.text = "Level %s Complete!" % level_name if level_name != "" else "Level Complete!"
	time_left_label.text = "%02d:%02d" % [int(time_left) / 60, int(time_left) % 60]
	value_label.text = "$" + format_number(stats.get("value", 0))
	continue_button.pressed.connect(_on_continue_pressed)

	await get_tree().create_timer(0.5).timeout
	for item in items:
		var item_stats = ItemStats.get_item(item)
		if not item_stats:
			continue
		var tex_rect := TextureRect.new()
		tex_rect.texture = load(item_stats.image_path)
		tex_rect.custom_minimum_size = Vector2(64, 64)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.tooltip_text = item_stats.item_name
		tex_rect.scale = Vector2.ZERO
		items_container.add_child(tex_rect)
		tex_rect.pivot_offset = tex_rect.size / 2.0
		create_tween().tween_property(tex_rect, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		await get_tree().create_timer(0.1).timeout

func _process(delta: float) -> void:
	camera.position.x += delta * 100.

func format_number(n: int) -> String:
	var s := str(n)
	var result := ""
	for i in s.length():
		if i > 0 and (s.length() - i) % 3 == 0:
			result += ","
		result += s[i]
	return result

func _on_continue_pressed():
	var next_scene = Global.level_stats.get("next_scene", null)
	if next_scene:
		Global.scene_manager.switch_scene_with_fade(next_scene, SceneManager.InTransitionEffects.STRAIGHT_TO_BLACK, SceneManager.OutTransitionEffects.FADE_OUT)
