extends Button

var _is_hovered : bool
var target_scale : float
@export var target : Control

func _ready() -> void:
	if not target:
		target = self

func _process(delta: float) -> void:
	target.pivot_offset = size/2
	if target.is_hovered() or target.has_focus():
		target_scale = 1.05
	else:
		target_scale = 1
	target.scale = target.scale.lerp(Vector2(1,1)*target_scale, delta * 5)
