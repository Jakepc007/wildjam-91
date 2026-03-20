extends MarginContainer
@onready var button: Button = $VBoxContainer/Up/HBoxContainer/Button


func _ready() -> void:
	_on_visibility_changed()

func _on_visibility_changed() -> void:
	if visible:
		button.grab_focus()
