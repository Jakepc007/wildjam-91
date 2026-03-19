extends Control

@export var level_1 : PackedScene
@export var options_menu : PackedScene

func _on_new_game_pressed() -> void:
	Global.scene_manager.switch_scene_with_fade(level_1)


func _on_options_pressed() -> void:
	Global.scene_manager.switch_scene(options_menu)


func _on_exit_pressed() -> void:
	get_tree().quit()
