extends Control

@export var level_1 : PackedScene
@export var options_menu : PackedScene
@onready var new_game: Button = $MenuContainer/MenuButtons/Control/VBoxContainer/MarginContainer/NewGame

func _on_new_game_pressed() -> void:
	if Global.scene_manager:
		Global.scene_manager.switch_scene_with_fade(level_1)
		#,\ SceneManager.InTransitionEffects.WIPE_IN,\
	 	#SceneManager.OutTransitionEffects.WIPE_OUT)


func _on_options_pressed() -> void:
	Global.scene_manager.switch_scene(options_menu)


func _ready() -> void:
	if Global.audio_manager:
		Global.audio_manager.play_track(AudioManager.Track.MAIN_MENU)
	new_game.grab_focus()



func _on_exit_pressed() -> void:
	get_tree().quit()
