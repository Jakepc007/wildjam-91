@tool
class_name Pickup extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var item: ItemStats.Item:
	set(value):
		item = value
		call_deferred("_update_sprite")
const HIGHLIGHT_SPEED = 5.

const ICON_WEIGHT := preload("res://assets/icons/weight.png")
const ICON_MONEY := preload("res://assets/icons/money.png")

func _ready() -> void:
	_update_sprite()

func _update_sprite() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if not spr:
		print("Sprite2D not found")
		return
	if not ItemStats.items.has(item):
		print("ItemStats does not have item: %s" % [item])
		return
	var image_path := ItemStats.get_item(item).image_path
	print("image path = %s" % [image_path])
	if image_path != "":
		var texture = load(image_path)
		if texture:
			spr.texture = texture

func _process(delta: float):
	if Engine.is_editor_hint():
		return
	if Player.closest_pickup == self:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.85, delta * HIGHLIGHT_SPEED * 2.)
	else:
		sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.75, delta * HIGHLIGHT_SPEED)
	queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint() or Player.closest_pickup != self:
		return
	if not ItemStats.items.has(item):
		return
	var stats := ItemStats.get_item(item)
	var font := ThemeDB.fallback_font
	var fs := 18
	var icon_s := Vector2(fs, fs)
	var padding := Vector2(10., 8.)
	var line_gap := 6.
	var row_h := float(fs) + line_gap
	var tooltip_w := 160.
	var tooltip_h := padding.y * 2. + row_h * 2. - line_gap
	var tip_pos := Vector2(-tooltip_w / 2., -80.)
	draw_rect(Rect2(tip_pos, Vector2(tooltip_w, tooltip_h)), Color(0., 0., 0., 0.75), true)
	var row1 := tip_pos + Vector2(padding.x, padding.y + fs)
	draw_texture_rect(ICON_WEIGHT, Rect2(row1 - Vector2(0., fs), icon_s), false)
	draw_string(font, row1 + Vector2(icon_s.x + 4., 0.), "%s lbs" % stats.weight, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var row2 := row1 + Vector2(0., row_h)
	draw_texture_rect(ICON_MONEY, Rect2(row2 - Vector2(0., fs), icon_s), false)
	draw_string(font, row2 + Vector2(icon_s.x + 4., 0.), "$%s" % stats.value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
