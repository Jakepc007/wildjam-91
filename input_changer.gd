extends Button

@export var action : String

func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)
	update_text()
	text = text.replace(" - Physical","")

func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		text = "Awaiting Input..."

func _unhandled_input(event: InputEvent) -> void:
	if pressed:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action,event)
		button_pressed = false
		release_focus()
		update_text()

func update_text():
	text = InputMap.action_get_events(action)[0].as_text()
