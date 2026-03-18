extends Control

var _level_1_path : String = "res://SecurityCamera/security_test.tscn"
var _options_menu_path : String = "res://menus/options_menu.tscn"

func _on_new_game_pressed() -> void:
	Global.scene_manager.switch_scene_with_fade(_level_1_path, SceneManager.InTransitionEffects.WIPE_IN,\
	 SceneManager.OutTransitionEffects.WIPE_OUT)


func _on_options_pressed() -> void:
	Global.scene_manager.switch_scene(_options_menu_path)


func _on_exit_pressed() -> void:
	get_tree().quit()
