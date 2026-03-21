@tool
class_name Pickup extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var item: ItemStats.Item:
	set(value):
		item = value
		call_deferred("_update_sprite")
const HIGHLIGHT_SPEED = 5.

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
