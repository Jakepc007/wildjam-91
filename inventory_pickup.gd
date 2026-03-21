extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

func set_image(image_path: String) -> void:
	if image_path != "":
		var texture = load(image_path)
		if texture:
			sprite.texture = texture
