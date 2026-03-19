extends Control

var _level_1_path : String = "res://SecurityCamera/security_test.tscn"
var _options_menu_path : String = "res://menus/options_menu.tscn"
@onready var new_game: Button = $MenuContainer/MenuButtons/Control/VBoxContainer/NewGame


func _ready() -> void:
	if Global.audio_manager:
		Global.audio_manager.play_track(AudioManager.Track.MAIN_MENU)
	new_game.grab_focus()

func _on_new_game_pressed() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if Global.scene_manager:
		Global.scene_manager.switch_scene_with_fade(_level_1_path, SceneManager.InTransitionEffects.WIPE_IN,\
	 	SceneManager.OutTransitionEffects.WIPE_OUT)


func _on_options_pressed() -> void:
	if Global.scene_manager:
		Global.scene_manager.switch_scene(_options_menu_path)


func _on_exit_pressed() -> void:
	get_tree().quit()
