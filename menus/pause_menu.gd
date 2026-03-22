extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_menu_path : String = "res://menus/main_menu.tscn"
@onready var options: VBoxContainer = $Options
@onready var buttons: PanelContainer = $Buttons
@onready var resume_button: Button = $Buttons/VBoxContainer/MarginContainer/Resume
@onready var options_button: Button = $Buttons/VBoxContainer/MarginContainer2/Options



func pause():
	get_tree().paused = true
	animation_player.play("blur")
	_on_visibility_changed()

func resume():
	if options.visible:
		_on_hide_options_pressed()
		return
	get_tree().paused = false
	animation_player.play_backwards("blur")

func on_start_pressed():
	if get_tree().paused:
		resume()
	else:
		pause()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		on_start_pressed()

func _on_resume_pressed() -> void:
	resume()


func _on_options_pressed() -> void:
	options.visible = true
	buttons.visible = false


func _on_main_menu_pressed() -> void:
	if Global.scene_manager:
		Global.scene_manager.animation_player.animation_finished.connect(\
		func(anim): get_tree().paused = false, Object.ConnectFlags.CONNECT_ONE_SHOT)
		Global.scene_manager.switch_scene_with_fade(load(main_menu_path))


func _on_hide_options_pressed() -> void:
	options.visible = false
	buttons.visible = true
	options_button.grab_focus()


func _on_visibility_changed() -> void:
	if visible and resume_button:
		resume_button.grab_focus()
